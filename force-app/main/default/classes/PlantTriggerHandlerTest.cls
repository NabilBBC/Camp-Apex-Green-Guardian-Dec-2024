
@isTest
private class PlantTriggerHandlerTest {

    @isTest
    static void InitializePlantFields() {
        CAMPX__Plant__c newPlant = new CAMPX__Plant__c(Name = 'FirstPlant');
        insert newPlant;

        CAMPX__Plant__c insertedPlant = [SELECT
                                            CAMPX__Soil_Type__c,
                                            CAMPX__Water__c,
                                            CAMPX__Sunlight__c
                                        FROM
                                            CAMPX__Plant__c
                                        LIMIT 1
                                        ];
        Assert.areEqual('All Purpose Potting Soil', insertedPlant.CAMPX__Soil_Type__c);
        Assert.areEqual( 'Once Weekly', insertedPlant.CAMPX__Water__c);
        assert.areEqual('Partial Sun', insertedPlant.CAMPX__Sunlight__c);
    }

    @isTest
    static void InitializePlantFieldsWithGardenAndExposure() {
        
        CAMPX__Garden__c BigGarden = new CAMPX__Garden__c(Name = 'Big Garden', CAMPX__Sun_Exposure__c = 'Full Shade');
        insert BigGarden;

        CAMPX__Plant__c newPlant = new CAMPX__Plant__c(Name = 'FirstPlant', CAMPX__Garden__c = BigGarden.id);
        insert newPlant;

        CAMPX__Plant__c insertedPlant = [SELECT
                                            CAMPX__Soil_Type__c,
                                            CAMPX__Water__c,
                                            CAMPX__Sunlight__c
                                        FROM
                                            CAMPX__Plant__c
                                        LIMIT 1
                                        ];
        Assert.areEqual('All Purpose Potting Soil', insertedPlant.CAMPX__Soil_Type__c);
        Assert.areEqual( 'Once Weekly', insertedPlant.CAMPX__Water__c);
        assert.areEqual('Full Shade', insertedPlant.CAMPX__Sunlight__c);
    }
}