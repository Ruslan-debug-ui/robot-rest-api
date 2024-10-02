*** Settings ***
Documentation   Users
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
T2_1 Users : My device (Get)
    :>Http Запрос        GET
    ...                  ${api_url}users/stlw455wpb
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S02_1.json
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      username=stlw455wpb


T2_2 Users : Non-existing id (Get)
    :>Http Запрос        GET
    ...                  ${api_url}users/zzzzz
    ...                  ${HEADERS}
    :>Проверяем статус   404    
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      detail=Not found

T2_3 Users : List of users (Get)
    :>Http Запрос        GET
    ...                  ${api_url}users
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S02_3.json

T2_4 Users : My login (Get)
    :>Http Запрос        GET
    ...                  ${api_url}users/me
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S02_4.json
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      username=mediascope_api


T2_5 Users : User Activity (Get)
    :>Http Запрос        GET
    ...                  ${api_url}users/stlw455wpb/activity
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S02_5.json
    
