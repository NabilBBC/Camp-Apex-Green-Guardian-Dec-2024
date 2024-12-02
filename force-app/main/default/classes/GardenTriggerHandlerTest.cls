@isTest
private class GardenTriggerHandlerTest {

    @isTest
    static void createOneNewGarden() {
        CAMPX__Garden__c newGarden = new CAMPX__Garden__c(Name = 'New Garden');
        insert newGarden;
        CAMPX__Garden__c insertedGarden = [  SELECT   CAMPX__Status__c,
                                                        CAMPX__Max_Plant_Count__c,
                                                        CAMPX__Minimum_Plant_Count__c,
                                                        CAMPX__Total_Plant_Count__c,
                                                        CAMPX__Total_Unhealthy_Plant_Count__c
                                                FROM    CAMPX__Garden__c
                                                LIMIT 1
                                            ];
        Assert.areEqual('Awaiting Resources' , insertedGarden.CAMPX__Status__c);
        Assert.areEqual(100, insertedGarden.CAMPX__Max_Plant_Count__c);
        Assert.areEqual(1, insertedGarden.CAMPX__Minimum_Plant_Count__c);
        Assert.areEqual(0, insertedGarden.CAMPX__Total_Plant_Count__c);
        Assert.areEqual(0, insertedGarden.CAMPX__Total_Unhealthy_Plant_Count__c);
    }
}