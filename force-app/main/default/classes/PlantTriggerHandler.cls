public with sharing class PlantTriggerHandler {
    public static void InitializePlantFields(List<CAMPX__Plant__c> newPlants) {
        Set<Id> gardenIds = new Set<Id>();
        for (CAMPX__Plant__c plant : newPlants) {
            if (plant.CAMPX__Garden__c != null) {
                gardenIds.add(plant.CAMPX__Garden__c);
            }
        }

        Map<Id, CAMPX__Garden__c> gardensMap = new Map<Id, CAMPX__Garden__c>([
            SELECT Id, CAMPX__Sun_Exposure__c FROM CAMPX__Garden__c WHERE Id IN :gardenIds
        ]);

        for (CAMPX__Plant__c plant : newPlants) {
            if (plant.CAMPX__Soil_Type__c == null) {
                plant.CAMPX__Soil_Type__c = 'All Purpose Potting Soil';
            }
            if (plant.CAMPX__Water__c == null) {
                plant.CAMPX__Water__c = 'Once Weekly';
            }
            if (plant.CAMPX__Sunlight__c == null && plant.CAMPX__Garden__c != null) {
                CAMPX__Garden__c relatedGarden = gardensMap.get(plant.CAMPX__Garden__c);
                if (relatedGarden != null && relatedGarden.CAMPX__Sun_Exposure__c != null) {
                    plant.CAMPX__Sunlight__c = relatedGarden.CAMPX__Sun_Exposure__c;
                }
            }
            if (plant.CAMPX__Sunlight__c == null) {
                plant.CAMPX__Sunlight__c = 'Partial Sun';
            }
        }
    }

    public static void aggregateTotalPlantCountAtInsert(List<CAMPX__Plant__c> addedPlants) {
        Set<Id> gardensToBeUpdatedIds = new Set<Id>();
        if (!addedPlants.isEmpty()) {
            for (CAMPX__Plant__c newPlant : addedPlants) {
                if (newPlant.CAMPX__Garden__c != null) {
                    gardensToBeUpdatedIds.add(newPlant.CAMPX__Garden__c);
                }
            }
            if (!gardensToBeUpdatedIds.isEmpty()) {      
                List<CAMPX__Garden__c> listOfGardens = [SELECT id, CAMPX__Total_Plant_Count__c,(SELECT id FROM CAMPX__Plants__r) FROM CAMPX__Garden__c WHERE Id IN :gardensToBeUpdatedIds];
                List<CAMPX__Garden__c> listOfGardensToBeUpdated = new List<CAMPX__Garden__c>();
                if (!listOfGardens.isEmpty()) {
                    for (CAMPX__Garden__c gardenToUpdate : listOfGardens) {
                        gardenToUpdate.CAMPX__Total_Plant_Count__c = gardenToUpdate.CAMPX__Plants__r.size();
                        listOfGardensToBeUpdated.add(gardenToUpdate);
                    }
                }
                if (!listOfGardensToBeUpdated.isEmpty()) {
                    update listOfGardensToBeUpdated;
                }
            }
        }
    }
    public static void aggregateTotalPlantCountAtUpdate(List<CAMPX__Plant__c> newPlantsList, Map<Id,CAMPX__Plant__c> oldMapPlants) {
        Set<Id> relatedGardensIdsSet = new Set<Id>();
        if (!newPlantsList.isEmpty()) {            
            for (CAMPX__Plant__c plantP : newPlantsList) {
                //Je récupère les ids des jardins à updater
                //nouveaux jardins
                if (plantP.CAMPX__Garden__c != null) {
                    relatedGardensIdsSet.add(plantP.CAMPX__Garden__c);
                }
                //anciens jardins
                if (!oldMapPlants.isEmpty()) {
                    if (oldMapPlants.get(plantP.Id).CAMPX__Garden__c != null) {
                        relatedGardensIdsSet.add(oldMapPlants.get(plantP.Id).CAMPX__Garden__c);
                    }
                }
            }
            if (!relatedGardensIdsSet.isEmpty()) {
                List<CAMPX__Garden__c> numberOfPlantsInTheGardens = [SELECT id, CAMPX__Total_Plant_Count__c, (SELECT id FROM CAMPX__Plants__r) FROM CAMPX__Garden__c WHERE Id IN :relatedGardensIdsSet];
                List<CAMPX__Garden__c> gardens2beUpdated = new List<CAMPX__Garden__c>();
                if (!numberOfPlantsInTheGardens.isEmpty()) {
                    for (CAMPX__Garden__c gardens2Update : numberOfPlantsInTheGardens) {
                        gardens2Update.CAMPX__Total_Plant_Count__c = gardens2Update.CAMPX__Plants__r.size();
                        gardens2beUpdated.add(gardens2Update);
                    }
                }
                if (!gardens2beUpdated.isEmpty()) {
                    update gardens2beUpdated;  
                } 
            }
        }
        
    }
    public static void aggregateTotalPlantCountAtDelete(List<CAMPX__Plant__c> triggeringPlants, List<CAMPX__Plant__c> oldPlants) {
        Set<Id> oldGardensIdsSet = new Set<Id>();
        if (!oldPlants.isEmpty()) {
            for (CAMPX__Plant__c deletedPlant : oldPlants) {
                if (deletedPlant.CAMPX__Garden__c != null) {
                    oldGardensIdsSet.add(deletedPlant.CAMPX__Garden__c);
                }
            }
            if (!oldGardensIdsSet.isEmpty()) {
                List<CAMPX__Garden__c> totalPlantsInTheGardens = [SELECT id, CAMPX__Total_Plant_Count__c, (SELECT id FROM CAMPX__Plants__r) FROM CAMPX__Garden__c WHERE Id IN :oldGardensIdsSet];
                List<CAMPX__Garden__c> bulkGardenToUpdate = new List<CAMPX__Garden__c>();
                if (!totalPlantsInTheGardens.isEmpty()) {
                    for (CAMPX__Garden__c gardenToUpdateWithTotalPlants : totalPlantsInTheGardens) {
                        gardenToUpdateWithTotalPlants.CAMPX__Total_Plant_Count__c = gardenToUpdateWithTotalPlants.CAMPX__Plants__r.size();
                        bulkGardenToUpdate.add(gardenToUpdateWithTotalPlants);
                    }
                } if (!bulkGardenToUpdate.isEmpty()) {
                    update bulkGardenToUpdate;
                }
            }
        }
    }
}