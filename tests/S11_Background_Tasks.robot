*** Settings ***
Documentation   Background tasks
Metadata        Author    Evgeniy.Ganusevich@mediascope.net

Library         RPA.HTTP
Library         RPA.FileSystem
Variables       variables.py
Resource        ../keywords/auth.robot
Resource        ../keywords/api.robot
Resource        ../keywords/logger.robot

Suite Setup     :>Suite Setup
Test Teardown   :>Logger Teardown



*** Test Cases ***
T11_1 Background tasks : Read Task Status (Get)
    :>Http Запрос        GET
    ...                  ${api_url}tasks/1
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S11_1.json
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      id=1

