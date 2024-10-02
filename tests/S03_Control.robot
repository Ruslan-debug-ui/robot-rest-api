*** Settings ***
Documentation   Группы и проекты
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
T3_1 Control : Список групп (Get)
    :>Http Запрос        GET
    ...                  ${api_url}groups
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S03_1.json


T3_2 Control : Группа 1 (Get)
    :>Http Запрос        GET
    ...                  ${api_url}groups/1
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S03_2.json
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      id=1

T3_3 Control : Список пользователей группы 1 (Get)
    :>Http Запрос        GET
    ...                  ${api_url}groups/1/users
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S03_3.json

T3_4 Control : Проекты (Get)
    :>Http Запрос        GET
    ...                  ${api_url}projects
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S03_4.json


T3_5 Control : Информация о проекте 1 (Get)
    :>Http Запрос        GET
    ...                  ${api_url}projects/1
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S03_5.json
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      name=Setmeter

T3_6 Control : Список групп в проекте (Get)
    :>Http Запрос        GET
    ...                  ${api_url}projects/1/groups
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S03_6.json

T3_7 Control : Список пользовaтелей в проекте 1 (Get)
    :>Http Запрос        GET
    ...                  ${api_url}projects/1/users
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S03_7.json
