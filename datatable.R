library(h2owave)
library(data.table)
library(plotly)
library(htmlwidgets)

datasets_sl <- lapply(ls('package:datasets'),function(x){if("data.frame" %in% class(eval(parse(text=x)))){x}})
datasets_sl[sapply(datasets_sl,is.null)] <- NULL
choices <- lapply(datasets_sl,function(x){ui_choice(as.character(x),as.character(x))})
tabs <- lapply(list("Table","Plot"),function(x){ui_tab(name=tolower(x),label=x)})
dt_action_groups <- data.table(read.csv("./artifacts/data.table.tut.txt"))
action_choices <- lapply(unique(dt_action_groups$groups),function(x){ui_choice(as.character(x),as.character(x))})

render_row <- function(row) {
    return(paste("\n|", paste(row, "|", collapse = '')))
}
render_text_box <- function(dataframe) {
    if ("data.table" %in% class(dataframe)) {
        headers = render_row(names(dataframe))
        demark = render_row(rep('-', length(names(dataframe))))
        body = paste(apply(dataframe, 1, render_row), collapse = '')
        return(paste(headers, demark, body))
    }
    else return(render_row(dataframe))
}
execute_function_on_rdatatable <- function(dataset, expression) {
    dataset_realise <- data.table::data.table(eval(parse(text = dataset)))
    response <- tryCatch({eval(parse(text = paste0("dataset_realise", "[", expression, ']')))},error = function(e){data.table("Error" = c(gsub("[\r\n]","",as.character(e))))})
    corrected_response <- if("data.table" %in% class(response)) response else { ret <- data.table(V1 = c(response)); names(ret) <- expression; return(ret)}
    return(corrected_response)
}

generate_guide <- function(group_choice){
    choice_data <- dt_action_groups[groups == group_choice,description]
    choice_output <- paste0(choice_data,"<br>",collapse=" ")
    return(choice_output)
}

render_plot <- function(data,x,y){
    fig <- plot_ly(data,x=x)
    fig <- fig %>% add_trace(y=y,name = deparse(substitute(y)), mode='markers')
    tryCatch({saveWidget(fig,"tempfile.html",selfcontained=T)},error = function(e){print(paste0("Error",e))})
}

serve <- function(qo) {
    qo$args$activity_group <- ifelse(is.null(qo$args$activity_group),"Subsetting rows using i",qo$args$activity_group)
    qo$args$app_dataset <- ifelse(is.null(qo$args$app_dataset),'iris',qo$args$app_dataset)
    qo$args$express_textbox <- ifelse(is.null(qo$args$express_textbox), '1:2,', qo$args$express_textbox)
    qo$args$menu <- ifelse(is.null(qo$args$menu),'table',qo$args$menu)
    qo$page$add_card("title", ui_header_card(
                                             box = '1 1 -1 1'
                                             , title = 'Interactive Learning App for R Data Table'
                                             , subtitle = 'Learn By Doing'
                                             , icon_color = 'black'
                                             ))

    qo$page$add_card("dataset_input", ui_form_card( box = '1 2 2 2'
                                                   ,items = list(
                                                                 ui_dropdown(name='app_dataset',label='Pick A Dataset', value = qo$args$app_dataset
                                                                             ,choices = choices,trigger=TRUE)
                                                                 )))

    qo$page$add_card("activity_group", ui_form_card( box = '3 2 3 2'
                                                   ,items = list(
                                                                 ui_dropdown(name='activity_group',label='What would you like to do with the dataset?', value = qo$args$activity_group
                                                                             ,choices = action_choices,trigger=TRUE)
                                                                 )))

    qo$page$add_card('express_display', ui_markdown_card(box = '6 2 -1 2'
                                                        , title = 'Expressions to Use'
                                                         ,content = generate_guide(qo$args$activity_group)
    ))

    qo$page$add_card("express_input", ui_form_card(box = '1 4 5 2'
                                                   , items = list(
                                                                  ui_textbox(name = 'express_textbox', label = 'Expression', value = qo$args$express_textbox, prefix = paste0(qo$args$app_dataset,'['), suffix = ']')
                                                                  , ui_button(name = 'express_execute', label = 'Execute Expression', primary = TRUE)
                                                   )
                                                   ))

    qo$page$add_card('activity_command', ui_markdown_card(box = '6 4 -1 2'
                                                         , title = 'Previously Executed Expression'
                                                         , content = paste0('<br><center><h2>', qo$args$app_dataset,'[', qo$args$express_textbox, ']', '</h2></center>')))

    if(qo$args$menu == 'plot' & file.exists("./tempfile.html")) {
        qo$page$add_card("example", ui_form_card(
                                                  box = '1 6 -1 10'
                                                  ,items = list(
                                                            ui_tabs(name='menu',value=qo$args$menu
                                                            ,items=tabs)
                                                      ,ui_frame(content=paste(readLines('./tempfile.html'),collapse='\n'),height='800px',width='1500px')
                                                  )
    ))
    }
    else {
      qo$page$add_card("example", ui_form_card(
                                             box = '1 6 -1 10'
                                             , items = list(
                                                            ui_tabs(name = 'menu', value = qo$args$menu
                                                            , items = tabs)
                                                            , ui_text(render_text_box(execute_function_on_rdatatable(qo$args$app_dataset, qo$args$express_textbox))
                                                            )
                                             )
                                             ))

    }


  qo$page$save()
}
app("/")
