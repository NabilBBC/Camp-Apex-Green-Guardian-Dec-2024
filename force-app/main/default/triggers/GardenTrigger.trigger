trigger GardenTrigger on CAMPX__Garden__c (before insert, after insert, before update) {
    if (trigger.isBefore && trigger.isInsert) {
        GardenTriggerHandler.initializeGardenFieldsUponCreation(trigger.new);
        GardenTriggerHandler.fillManagerStartDate(trigger.new, trigger.oldmap);

    }
    if (trigger.isBefore && trigger.isUpdate) {
        GardenTriggerHandler.createTaskUponGardenUpdate(trigger.new, trigger.oldmap);
        GardenTriggerHandler.transferOpenTasksBetweenManagers(trigger.new, trigger.oldmap);
        GardenTriggerHandler.deleteUncompletedTasksWithoutManager(trigger.new, trigger.oldmap);
        GardenTriggerHandler.fillManagerStartDate(trigger.new, trigger.oldmap);
        GardenTriggerHandler.clearManagerStartDate(trigger.new, trigger.oldmap);
    }
    if (trigger.isAfter && trigger.isInsert) {
        GardenTriggerHandler.createTaskUponGardenCreation(trigger.new);
    }
}