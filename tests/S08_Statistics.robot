*** Settings ***
Documentation   Statistics
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
T8_1 Statistics : Get Aggregated Total Objects (Get)
    :>Http Запрос        GET
    ...                  ${api_url}stats/aggregated/total
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S08_1.json

T8_2 Statistics : Get Aggregated Active Devices (Get)
    :>Http Запрос        GET
    ...                  ${api_url}stats/aggregated/active
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S08_2.json

T8_3 Statistics : Get Aggregated Active Recognition Devices (Get)
    :>Http Запрос        GET
    ...                  ${api_url}stats/aggregated/active-recognition
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S08_3.json

T8_4 Statistics : Get Aggregated Online (Get)
    :>Http Запрос        GET
    ...                  ${api_url}stats/aggregated/online
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S08_4.json

T8_5 Statistics : Get Category Viewing Stats (Get)
    :>Http Запрос        GET
    ...                  ${api_url}stats/meters/stlw455wpb/tv-viewing
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S08_5.json