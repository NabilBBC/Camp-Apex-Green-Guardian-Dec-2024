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
                    if (garden.CAMPX__Manager__c != null) {        
                        for (Task taskToUpdate : tasksToTransfer) {
                            taskToUpdate.OwnerId = garden.CAMPX__Manager__c;
                            tasksToUpdate.add(taskToUpdate);                   
                        }
                    }
                }
            }
        } update tasksToUpdate;        
    }

    public static void deleteUncompletedTasksWithoutManager(List <CAMPX__Garden__c> newGs, Map<Id, CAMPX__Garden__c> oldgGMap) {
        List<task> tasksUncompleted = [ SELECT subject, WhatId, ownerId, Status
                                        FROM task
                                        WHERE Status <> 'Completed'
                                        AND subject = 'Acquire Plants'
                                      ];
        List<Task> tasksToDelete = new List<Task>();
        for (CAMPX__Garden__c newG : newGs) {
            CAMPX__Garden__c oldG = oldgGMap.get(newG.Id);
            if (oldG.CAMPX__Manager__c != null) {
                if (newG.CAMPX__Manager__c == null) {
                    for (task taskToDelete : tasksUncompleted) {
                        if (taskToDelete.WhatId == newG.Id) {
                            tasksToDelete.add(taskToDelete);
                        }
                    }
                }
            }
        } delete tasksToDelete;
    }

    public static void fillManagerStartDate(List <CAMPX__Garden__c> newGs, Map<Id, CAMPX__Garden__c> oldgGMap) {
        for (CAMPX__Garden__c triggGarden : newGs) {
            if (Trigger.isInsert) {
                if (triggGarden.CAMPX__Manager__c != null) {
                    triggGarden.CAMPX__Manager_Start_Date__c = system.today();
                    }
                }
            if (Trigger.isUpdate) {
                if (oldgGMap != null) {
                    CAMPX__Garden__c oldGarden = oldgGMap.get(triggGarden.id);
                    if ((oldGarden.CAMPX__Manager__c == null && triggGarden.CAMPX__Manager__c != null)
                    || (oldGarden.CAMPX__Manager__c != null && (oldGarden.CAMPX__Manager__c <> triggGarden.CAMPX__Manager__c))) {
                        triggGarden.CAMPX__Manager_Start_Date__c = system.today();
                    }
                }
            }
        }
    }


    public static void clearManagerStartDate(List <CAMPX__Garden__c> newGs, Map<Id, CAMPX__Garden__c> oldgGMap) {
        for (CAMPX__Garden__c garden2Update : newGs) {
            if (oldgGMap != null) {
                CAMPX__Garden__c oldGarden = oldgGMap.get(garden2Update.id);
                if (oldGarden.CAMPX__Manager_Start_Date__c != null) {
                    if (garden2Update.CAMPX__Manager__c == null) {
                        garden2Update.CAMPX__Manager_Start_Date__c = null;
                    }
                }
            }
        }
    }

    public static void calculateCapacityAtInsert(List <CAMPX__Garden__c> newGardens) {
        if (!newGardens.isempty()) {
            for (CAMPX__Garden__c garden : newGardens) {
                if (garden.CAMPX__Total_Plant_Count__c != null && garden.CAMPX__Max_Plant_Count__c != null) {
                    if (garden.CAMPX__Total_Plant_Count__c > 0 && garden.CAMPX__Max_Plant_Count__c > 0) {
                        garden.CAMPX__Capacity__c = (garden.CAMPX__Total_Plant_Count__c/garden.CAMPX__Max_Plant_Count__c)*100;
                    }
                if (garden.CAMPX__Total_Plant_Count__c <= 0 || garden.CAMPX__Max_Plant_Count__c <= 0 || garden.CAMPX__Total_Plant_Count__c == null || garden.CAMPX__Max_Plant_Count__c == null) {
                    garden.CAMPX__Capacity__c = 0;
                    }
                }
            }
        }
    }

    public static void calculateCapacityAtUpdate(List<CAMPX__Garden__c> recentGardens, Map<Id, CAMPX__Garden__c> oldGardensMap) {
        if (recentGardens.isEmpty()) return;
    
        for (CAMPX__Garden__c currentGarden : recentGardens) {
            CAMPX__Garden__c oldGarden = oldGardensMap.get(currentGarden.Id);
            if (oldGarden == null) continue;
    
            // Only process if either count has changed
            if (currentGarden.CAMPX__Total_Plant_Count__c != oldGarden.CAMPX__Total_Plant_Count__c
                || currentGarden.CAMPX__Max_Plant_Count__c != oldGarden.CAMPX__Max_Plant_Count__c) {
                
                // Set capacity to 0 if either value is null or <= 0
                if (currentGarden.CAMPX__Total_Plant_Count__c == null 
                    || currentGarden.CAMPX__Max_Plant_Count__c == null
                    || currentGarden.CAMPX__Total_Plant_Count__c <= 0 
                    || currentGarden.CAMPX__Max_Plant_Count__c <= 0) {
                    currentGarden.CAMPX__Capacity__c = 0;
                } else {
                    // Calculate capacity only if both values are positive
                    currentGarden.CAMPX__Capacity__c = (currentGarden.CAMPX__Total_Plant_Count__c / currentGarden.CAMPX__Max_Plant_Count__c) * 100;
                }
            }
        }
    }

    public static void calculateGardenHealthIndex(List <CAMPX__Garden__c> triggeredGardens, Map<Id, CAMPX__Garden__c> oldGardensMap) {
        CAMPX__Garden__c oldGarden = new CAMPX__Garden__c();
        if (!triggeredGardens.isempty()) {
            for (CAMPX__Garden__c triggeredGarden : triggeredGardens) {
                if (oldGardensMap.get(triggeredGarden.id) != null) {
                    oldGarden = oldGardensMap.get(triggeredGarden.id);
                }
                if (triggeredGarden.CAMPX__Total_Plant_Count__c == 0 || triggeredGarden.CAMPX__Total_Plant_Count__c == null ) {
                    triggeredGarden.CAMPX__Health_Index__c = 0;
                }
                if ((oldGarden.CAMPX__Total_Plant_Count__c != triggeredGarden.CAMPX__Total_Plant_Count__c)
                    || (oldGarden.CAMPX__Total_Unhealthy_Plant_Count__c != triggeredGarden.CAMPX__Total_Unhealthy_Plant_Count__c)) {
                    if (triggeredGarden.CAMPX__Total_Plant_Count__c > 0) {
                        triggeredGarden.CAMPX__Health_Index__c = ((triggeredGarden.CAMPX__Total_Plant_Count__c - triggeredGarden.CAMPX__Total_Unhealthy_Plant_Count__c)
                        / triggeredGarden.CAMPX__Total_Plant_Count__c * 100).setScale(2, System.RoundingMode.HALF_UP);
                    } 
                }
            }                
        }   
    } 

    public static void updateGardenStatus(List <CAMPX__Garden__c> triggeringGardens) {
        if (!triggeringGardens.isempty()) {
            for (CAMPX__Garden__c garden : triggeringGardens) {
                if (garden.CAMPX__Status__c == 'Permanent Closure'){
                    continue;
                }
                if (garden.CAMPX__Capacity__c == 0) {
                    garden.CAMPX__Status__c = 'Temporary Closure';
                    continue;
                }
                if (garden.CAMPX__Capacity__c > 100) {
                    garden.CAMPX__Status__c = 'Over Capacity';
                    continue;
                }                    
                if ((garden.CAMPX__Capacity__c >= 70 && garden.CAMPX__Capacity__c <= 100)
                    &&(garden.CAMPX__Total_Plant_Count__c >= garden.CAMPX__Minimum_Plant_Count__c)
                    && garden.CAMPX__Health_Index__c >= 70){
                    garden.CAMPX__Status__c = 'Operational';
                    continue;
                }
                if ((garden.CAMPX__Capacity__c > 0 && garden.CAMPX__Capacity__c < 70)
                || garden.CAMPX__Health_Index__c < 70
                || garden.CAMPX__Total_Plant_Count__c < garden.CAMPX__Minimum_Plant_Count__c){
                garden.CAMPX__Status__c = 'Awaiting Resources';
                }
            }
        }
    }

    public static void avoidNegativeValues(List <CAMPX__Garden__c> triggeringGardens) {
        if (triggeringGardens.isEmpty()) return;{
        }
        for (CAMPX__Garden__c triggGarden : triggeringGardens) {
            if (triggGarden.CAMPX__Total_Plant_Count__c < 0
                || triggGarden.CAMPX__Max_Plant_Count__c < 0
                || triggGarden.CAMPX__Total_Plant_Count__c < 0
                || triggGarden.CAMPX__Total_Unhealthy_Plant_Count__c < 0) {
            triggGarden.addError('Plant Count fields must be greater than or equal to zero.');
            }
        }
    }

    public static void avoidNullValuesInMinMaxPlantCount(List <CAMPX__Garden__c> triggeringGardens) {
        if (triggeringGardens.isEmpty()) return;{
        }
        for (CAMPX__Garden__c triggGarden : triggeringGardens) {
            if (triggGarden.CAMPX__Total_Plant_Count__c != null && triggGarden.CAMPX__Total_Plant_Count__c > 0){
                if (triggGarden.CAMPX__Minimum_Plant_Count__c == null || triggGarden.CAMPX__Max_Plant_Count__c == null) {
                    triggGarden.addError('Maximum and Minimum Plant Count fields cannot be blank when there are plants in the Garden.');
                }
            }
        }
    }
} 