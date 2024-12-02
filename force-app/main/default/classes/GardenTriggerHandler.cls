public with sharing class GardenTriggerHandler {

    public static void InitializeGardenFieldsUponCreation(List <CAMPX__Garden__c> newGardens) {
        List<CAMPX__Garden__c> gardensToInsert = new List<CAMPX__Garden__c>();
        for (CAMPX__Garden__c garden : newGardens) {
            garden.CAMPX__Status__c = 'Awaiting Resources';
            garden.CAMPX__Max_Plant_Count__c = 100;
            garden.CAMPX__Minimum_Plant_Count__c = 1;
            garden.CAMPX__Total_Plant_Count__c = 0;
            garden.CAMPX__Total_Unhealthy_Plant_Count__c = 0;
            gardensToInsert.add(garden);
        }
    }
}