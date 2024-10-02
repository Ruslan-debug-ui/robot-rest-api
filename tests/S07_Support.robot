*** Settings ***
Documentation   Support
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
T7_1 Support : List Tickets (Get)
    :>Http Запрос        GET
    ...                  ${api_url}support/tickets
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S07_1.json

T7_2 Support : Ticket 1 (Get)
    :>Http Запрос        GET
    ...                  ${api_url}support/tickets/1
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S07_2.json
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      id=1