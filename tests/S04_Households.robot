*** Settings ***
Documentation   Домохозяйства
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
T4_1 Households : Список домохозяйств (Get)
    :>Http Запрос        GET
    ...                  ${api_url}households
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S04_1.json


T4_2 Households : Домохозяйство 1 (Get)
    :>Http Запрос        GET
    ...                  ${api_url}households/1
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S04_2.json

T4_3 Households : Список зрителей домохозяйства 1 (Get)
    :>Http Запрос        GET
    ...                  ${api_url}households/1/panelists
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S04_3.json
    :>Проверяем JSON         ${RSP_JSON}[0] 
    ...                      household_id=1

T4_4 Households : Список устройств домохозяйства 1 (Get)
    :>Http Запрос        GET
    ...                  ${api_url}households/1/meters
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S04_4.json
    :>Проверяем JSON         ${RSP_JSON}[0] 
    ...                      household_id=1

