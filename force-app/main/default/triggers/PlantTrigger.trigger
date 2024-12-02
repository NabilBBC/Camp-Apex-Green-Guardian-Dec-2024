trigger PlantTrigger on CAMPX__Plant__c (before insert) {
    PlantTriggerHandler.InitializePlantFields(trigger.new);
}