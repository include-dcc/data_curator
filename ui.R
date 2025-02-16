# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
# This interface has been modified to be used specifically on Sage Bionetworks Synapse pages
# to log into Synapse as the currently logged in user from the web portal using the session token.
#
# https://www.synapse.org

ui <- shinydashboardPlus::dashboardPage(
  title = "Data Curator",
  skin = "purple",
  dashboardHeader(
    titleWidth = 250,
    title = tagList(
      span(class = "logo-lg", "Data Curator"),
      span(class = "logo-mini", "DCA")
    ),
    leftUi = tagList(
      dropdownBlock(
        id = "header_selection_dropdown",
        title = "Selection",
        icon = icon("sliders"),
        badgeStatus = "info",
        fluidRow(
          lapply(dropdown_types, function(x) {
            div(
              id = paste0("header_content_", x),
              selectInput(
                inputId = paste0("header_dropdown_", x),
                label = NULL,
                choices = character(0)
              )
            )
          }),
          actionButton("btn_header_update", NULL, icon("rotate"), class = "btn-shiny-effect")
        )
      )
    ),
    tags$li(
      class = "dropdown", id = "INCLUDE_logo",
      tags$a(
        href = "https://includedcc.org/",
        target = "_blank",
        tags$img(
          height = "40px", alt = "INCLUDE LOGO",
          src = "img/INCLUDE DCC Logo-01.png"
        )
      )
    )
  ),
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      id = "tabs",
      menuItem(
        "Select your Dataset",
        tabName = "tab_data",
        icon = icon("arrow-pointer")
      ),
      menuItem(
        "Get Metadata Template",
        tabName = "tab_template",
        icon = icon("table")
      ),
      menuItem(
        "Submit & Validate Metadata",
        tabName = "tab_upload",
        icon = icon("upload")
      ),
      # add sidebar footer here
      tags$a(
        id = "sidebar_footer", `data-toggle` = "tab",
        tags$div(icon("heart")),
        tags$footer(HTML('Supported by the INCLUDE Data Coordinating Center <br/>
                  Powered by <i class="far fa-heart"></i> and Sage Bionetworks'))
      )
    )
  ),
  dashboardBody(
    tags$head(
      tags$style(sass(sass_file("www/scss/main.scss"))),
      singleton(includeScript("www/js/readCookie.js")),
      tags$script(htmlwidgets::JS("setTimeout(function(){history.pushState({}, 'Data Curator', window.location.pathname);},2000);"))
    ),
    # load dependencies
    use_notiflix_report(width = "400px"),
    use_waiter(),
    tabItems(
      # data selection & dashboard tab content
      tabItem(
        tabName = "tab_data",
        h2("Set Dataset and Data Type for Curation"),
        fluidRow(
          box(
            id = "box_pick_project",
            status = "primary",
            width = 6,
            title = "Choose a Project and Folder: ",
            selectInput(
              inputId = "dropdown_project",
              label = "Project:",
              choices = "Generating..."
            ),
            selectInput(
              inputId = "dropdown_folder",
              label = "Dataset:",
              choices = "Generating..."
            ),
            helpText(
              "If your recently updated folder does not appear, please wait for a few minutes and refresh"
            )
          ),
          box(
            id = "box_pick_manifest",
            status = "primary",
            width = 6,
            title = "Choose a Data Type: ",
            selectInput(
              inputId = "dropdown_datatype",
              label = "Data Type:",
              choices = "Generating..."
            )
          )#,
          #dashboardUI("dashboard")
        ),
        switchTabUI("switchTab1", direction = "right")
      ),
      # template tab item
      tabItem(
        tabName = "tab_template",
        useShinyjs(),
        h2("Download Template for Selected Folder"),
        fluidRow(
          box(
            title = "Get Link, Annotate, and Download Template as CSV",
            status = "primary",
            width = 12,
            actionButton("btn_template", "Click to Generate Google Sheets Template",
              class = "btn-primary-color"
            ),
            hidden(
              div(
                id = "div_template_warn",
                height = "100%",
                htmlOutput("text_template_warn")
              ),
              div(
                id = "div_template",
                height = "100%",
                htmlOutput("text_template")
              )
            ),
            helpText("This link will leads to an empty template or your previously submitted template with new files if applicable.")
          )
        ),
        switchTabUI("switchTab2", direction = "both")
      ),
      # upload & submit tab content
      tabItem(
        tabName = "tab_upload",
        h2("Submit & Validate a Filled Metadata Template"),
        fluidRow(
          box(
            title = "Upload Filled Metadata as a CSV",
            status = "primary",
            width = 12,
            csvInfileUI("inputFile")
          ),
          box(
            title = "Metadata Preview",
            collapsible = TRUE,
            status = "primary",
            width = 12,
            DTableUI("tbl_preview")
          ),
          box(
            title = "Validate Filled Metadata",
            status = "primary",
            collapsible = TRUE,
            width = 12,
            actionButton("btn_validate", "Validate Metadata", class = "btn-primary-color"),
            div(
              id = "div_validate",
              height = "100%",
              ValidationMsgUI("text_validate")
            ),
            DTableUI("tbl_validate"),
            uiOutput("val_gsheet"),
            helpText(
              HTML("If you have an error, please try editing locally or on google sheet.
                  Reupload your CSV and press the validate button as needed.")
            )
          ),
          box(
            title = "Submit Validated Metadata to Synapse",
            status = "primary",
            width = 12,
            uiOutput("submit")
          )
        ),
        switchTabUI("switchTab3", direction = "left")
      )
    ),
    # waiter loading screen
    dcWaiter("show", landing = TRUE)
  )
)

uiFunc <- function(req) {
  if (!has_auth_code(parseQueryString(req$QUERY_STRING))) {
    authorization_url <- oauth2.0_authorize_url(api, app, scope = scope)
    return(tags$script(HTML(sprintf(
      "location.replace(\"%s\");",
      authorization_url
    ))))
  } else {
    ui
  }
}
