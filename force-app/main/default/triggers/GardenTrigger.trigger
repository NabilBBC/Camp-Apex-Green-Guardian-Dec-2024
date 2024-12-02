trigger GardenTrigger on CAMPX__Garden__c (before insert) {
    GardenTriggerHandler.InitializeGardenFieldsUponCreation(trigger.new);
}