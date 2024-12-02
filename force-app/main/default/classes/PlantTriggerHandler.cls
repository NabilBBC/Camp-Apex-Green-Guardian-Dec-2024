public with sharing class PlantTriggerHandler {
    public static void InitializePlantFields (List <CAMPX__Plant__c> newPlants) {

        CAMPX__Garden__c relatedGarden = new CAMPX__Garden__c();

        for (CAMPX__Plant__c plant : newPlants) {
            if (plant.CAMPX__Soil_Type__c == null) {
                plant.CAMPX__Soil_Type__c = 'All Purpose Potting Soil';
            }
            if (plant.CAMPX__Water__c == null) {
                plant.CAMPX__Water__c = 'Once Weekly';
            }
            if (plant.CAMPX__Sunlight__c == null && plant.CAMPX__Garden__c != null) {
                relatedGarden = [SELECT Id, CAMPX__Sun_Exposure__c FROM CAMPX__Garden__c WHERE Id = :plant.CAMPX__Garden__c LIMIT 1];
                if (relatedGarden.CAMPX__Sun_Exposure__c != null) {
                    plant.CAMPX__Sunlight__c = relatedGarden.CAMPX__Sun_Exposure__c;
                }
            }
            if (plant.CAMPX__Sunlight__c == null && (plant.CAMPX__Garden__c == null || plant.CAMPX__Garden__r.CAMPX__Sun_Exposure__c == null)) {
                plant.CAMPX__Sunlight__c = 'Partial Sun';
            }
        }
    }
}