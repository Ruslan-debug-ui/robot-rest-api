*** Settings ***
Documentation   Зрители
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
T5_1 Households : Профиль зрителя с id 1 (Get)
    :>Http Запрос        GET
    ...                  ${api_url}panelists/1
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S05_1.json
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      id=1