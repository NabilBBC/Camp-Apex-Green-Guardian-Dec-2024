public with sharing class GardenTriggerHandler {

    public static void initializeGardenFieldsUponCreation(List <CAMPX__Garden__c> newGardens) {
        List<CAMPX__Garden__c> gardensToInsert = new List<CAMPX__Garden__c>();
        for (CAMPX__Garden__c garden : newGardens) {
            if (garden.CAMPX__Status__c == null) {                
                garden.CAMPX__Status__c = 'Awaiting Resources';
            }
            if (garden.CAMPX__Max_Plant_Count__c == null) {                
                garden.CAMPX__Max_Plant_Count__c = 100;
            }
            if (garden.CAMPX__Minimum_Plant_Count__c == null) {
                garden.CAMPX__Minimum_Plant_Count__c = 1;
            }
            if (garden.CAMPX__Total_Plant_Count__c == null) {
                garden.CAMPX__Total_Plant_Count__c = 0;
            }
            if (garden.CAMPX__Total_Unhealthy_Plant_Count__c == null) {
                garden.CAMPX__Total_Unhealthy_Plant_Count__c = 0;
            }
            gardensToInsert.add(garden);
        }
    }

    public static void createTaskUponGardenCreation(List <CAMPX__Garden__c> listOfNewGardens) {
        id managerId;
        List<Task> listOfTasksToInsert = new List<Task>();
        for (CAMPX__Garden__c gardenToBeModified : listOfNewGardens) {
            if (gardenToBeModified.CAMPX__Manager__c != null) {
                managerId = gardenToBeModified.CAMPX__Manager__c;
                Task newTask = new Task();
                newTask.OwnerId = managerId;
                newTask.WhatId = gardenToBeModified.id;
                newTask.Subject = 'Acquire Plants';
                listOfTasksToInsert.add(newTask);
            }
        }insert listOfTasksToInsert;
    }

    public static void createTaskUponGardenUpdate(List <CAMPX__Garden__c> listOfNewGardens, Map<Id, CAMPX__Garden__c> oldGardensMap) {
        List<Task> listOfNewTasksToInsert = new List<Task>();
        id idOfTheNewManager;
        for (CAMPX__Garden__c changingGarden : listOfNewGardens) {
            CAMPX__Garden__c oldGarden = oldGardensMap.get(changingGarden.id);
            if (oldGarden.CAMPX__Manager__c == null && changingGarden.CAMPX__Manager__c != null)
            {
                idOfTheNewManager = changingGarden.CAMPX__Manager__c;
                Task brandNewTask = new Task();
                brandNewTask.OwnerId = idOfTheNewManager;
                brandNewTask.WhatId = changingGarden.id;
                brandNewTask.Subject = 'Acquire Plants';
                listOfNewTasksToInsert.add(brandNewTask);
            }
        }insert listOfNewTasksToInsert;
    }

    public static void transferOpenTasksBetweenManagers(List <CAMPX__Garden__c> listOfNewGardens, Map<Id, CAMPX__Garden__c> oldGardensMap) {
        List<Task> tasksToUpdate = new List<Task>();
        for (CAMPX__Garden__c garden : listOfNewGardens) {
            CAMPX__Garden__c oldGarden = oldGardensMap.get(garden.id);
            if (oldGarden.CAMPX__Manager__c != null) {
                if (oldGarden.CAMPX__Manager__c <> garden.CAMPX__Manager__c) {
                    List<Task> tasksToTransfer = [SELECT id, WhatId, ownerId, subject, Status
                                        FROM Task
                                        WHERE OwnerId = :oldGarden.CAMPX__Manager__c
                                        AND Status <> 'Completed'
                                        AND WhatId = :garden.id
                                        AND subject = 'Acquire Plants'
                                        ];
                    for (Task taskToUpdate : tasksToTransfer) {
                        taskToUpdate.OwnerId = garden.CAMPX__Manager__c;
                        tasksToUpdate.add(taskToUpdate);                   
                    }
                }
            }
        } update tasksToUpdate;        
    }
}