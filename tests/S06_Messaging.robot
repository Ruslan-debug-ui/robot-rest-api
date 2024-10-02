*** Settings ***
Documentation   Сообщения
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
T6_1 Messaging : Список сообщений (Get)
    :>Http Запрос        GET
    ...                  ${api_url}push/messages
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S06_1.json

T6_2 Messaging : Просмотр сообщения (Get)
    :>Http Запрос        GET
    ...                  ${api_url}push/messages/2d4a17fc-cfcd-4be5-a468-01a9b4481f3a
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S06_2.json
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      uuid=2d4a17fc-cfcd-4be5-a468-01a9b4481f3a