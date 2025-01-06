trigger PlantTrigger on CAMPX__Plant__c (before insert, after delete, after insert, after update, after undelete){
    if (trigger.isBefore && (trigger.isInsert)){
        PlantTriggerHandler.initializePlantFields(trigger.new);
    }
    if (trigger.isAfter && (trigger.isInsert || trigger.isUndelete)){
        PlantTriggerHandler.aggregateTotalPlantCountAtInsert(trigger.new);
    }
    if (trigger.isAfter && trigger.isUpdate){
        PlantTriggerHandler.aggregateTotalPlantCountAtUpdate(trigger.new, trigger.oldMap);
    }
    if (trigger.isAfter && trigger.isDelete){
        PlantTriggerHandler.aggregateTotalPlantCountAtDelete(trigger.new, trigger.old);
    }
}