*** Settings ***
Documentation       Ключевые слова для Suite
Library             RPA.HTTP
Library             String
Library             Collections
Library             RPA.FileSystem
Library             OperatingSystem
Library             RPA.Browser.Selenium
Resource            api.robot
Resource            auth.robot

*** Variables ***
${RED}       "\\033[91m"
${YELLOW}    "\\033[93m"
${BLUE}      "\\033[94m"
${PURPLE}    "\\033[95m"
${DEF}       "\\033[0m"
${JIRA_URL}  https://tracker.yandex.ru

*** Keywords ***
:>Logger Teardown
    
    #Раскрашиваем файлы
    ${red}=         Evaluate  ${RED}
    ${yellow}=      Evaluate  ${YELLOW}
    ${blue}=        Evaluate  ${BLUE}
    ${def}=         Evaluate  ${DEF}

    @{bug_lst}=     Create List


    FOR    ${tag}    IN    @{TEST TAGS}
        ${contains}=   Evaluate   "Bug" in """${tag}"""

        IF   ${contains}
            ${bug_tag}=       Replace String    ${tag}    Bug${SPACE}    ${EMPTY}
            Append To List    ${bug_lst}    ${bug_tag}
        END
    END


    IF    "@{bug_lst}" != "@{EMPTY}"
        
        IF    "${TEST STATUS}" == "FAIL"
            Log To Console    \nТест не прошел но так и толжно быть из за:
        END

        IF    "${TEST STATUS}" == "PASS"      
            Log To Console    \nТест прошел но есть инциденты которые нужно закрыть:
        END            
        
        FOR    ${bug}    IN    @{bug_lst}
            ${jira_lnk}=   Set Variable    ${blue}${JIRA_URL}/${bug}${def}

            IF    "${TEST STATUS}" == "FAIL"
                Log To Console    • ${red}${bug}${def} ► ${jira_lnk}
            ELSE
                Log To Console    • ${yellow}${bug}${def} ► ${jira_lnk}
            END

        END

    ELSE

        IF  "${TEST STATUS}" == "FAIL"
            ##Логируем параметры запроса
            
            #Получаем все переменные
            ${variables}=  Get variables

            #Выводим параметры запроса если есть словарь REQUEST_DICT
            IF    "\&{REQUEST_DICT}" in $variables

                Log To Console    \n\n*** REQUEST ***

                IF  'type' in ${REQUEST_DICT} and "${REQUEST_DICT}[type]"!="${EMPTY}"
                    Log To Console    ${REQUEST_DICT}[type]    no_newline=True
                END

                IF  'url' in ${REQUEST_DICT} and "${REQUEST_DICT}[url]"!="${EMPTY}"
                    Log To Console    ${SPACE}${REQUEST_DICT}[url]  no_newline=True
                END

                IF  'params' in ${REQUEST_DICT} and ${REQUEST_DICT}[params]

                    &{params_dict}=    Set Variable    ${REQUEST_DICT}[params]

                    Log To Console    \n\nParams:${SPACE}    no_newline=True
                    FOR    ${key}    IN    @{params_dict.keys()}
                        Log To Console    ${key}=${params_dict["${key}"]} ${SPACE}    no_newline=True
                    END
                ELSE
                    Log To Console    \n\nParams: -    no_newline=True
                END

                IF  'headers' in ${REQUEST_DICT} and ${REQUEST_DICT}[headers]

                    Log To Console    \n\nHeaders:\n${REQUEST_DICT}[headers]    no_newline=True
                END

                Log To Console    \n

            END
    
            #Выводим ответ если есть перменная RSP
            IF    "\@{RSP}" in $variables

                Log To Console    \n*** RESPONSE ***
                Log To Console    ${RSP.status_code} ${RSP.url}
                Log To Console    \nBody:\n${RSP.text}
                Log To Console    \nHeaders:\n${RSP.headers}
                Log To Console    \n
            END
        END

    END


# :>>Suite Setup
#     ${purple}=          Evaluate  ${PURPLE}
#     ${def}=             Evaluate  ${DEF}
#     Log To Console      \n${purple}Старт тестов: ${SUITE DOCUMENTATION}${def}\n


# :>>Suite Teardown
#     #Переносим логи из корня
#     ${is_not_output}=   Evaluate   "output" not in """${OUTPUT DIR}"""
    
#     #Если логирование не идет в каталог output
#     IF    ${is_not_output}
        
#         ${dir_not_exist}=       Does Directory Not Exist    ./output
        
#         # Создаем каталог output если он не существует
#         IF    ${dir_not_exist}     
#             Create Directory    ./output    exist_ok=true
#         END

#         ${output_exist}=     Does File Exist    ${OUTPUT FILE}
#         ${log_exist}=        Does File Exist    ${LOG FILE}
#         ${report_exist}=     Does File Exist    ${REPORT FILE}

#         IF    ${output_exist}
#             RPA.FileSystem.Copy File     ${OUTPUT FILE}   ./output/output.xml
#         END
#         IF    ${log_exist}
#             RPA.FileSystem.Copy File     ${LOG FILE}      ./output/log.html
#         END
#         IF    ${report_exist}
#             RPA.FileSystem.Copy File     ${REPORT FILE}   ./output/report.html
#         END
#     END