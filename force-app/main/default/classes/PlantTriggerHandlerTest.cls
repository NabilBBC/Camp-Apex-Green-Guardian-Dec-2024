
@isTest
private class PlantTriggerHandlerTest {

    @isTest
    static void initializePlantFields() {
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
    static void initializePlantFieldsWithGardenAndExposure() {
        
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

    @isTest
    static void insertPlantWithGarden() {
        
        CAMPX__Garden__c garden = new CAMPX__Garden__c(Name = 'Garden');
        insert garden;

        CAMPX__Plant__c newPlant = new CAMPX__Plant__c(Name = 'FirstPlant', CAMPX__Garden__c = garden.id);
        insert newPlant;

        CAMPX__Garden__c insertedGarden =   [
                                            SELECT  id,
                                                    CAMPX__Total_Plant_Count__c
                                            FROM    CAMPX__Garden__c
                                            LIMIT   1
                                            ];
        Assert.areEqual(1, insertedGarden.CAMPX__Total_Plant_Count__c, 'Garden should have at least 1 plant in total count');
    }

    @isTest
    static void insertAndUpdatePlantWithGarden() {
        
        List<CAMPX__Garden__c> listOfGardens = new List<CAMPX__Garden__c>();
        CAMPX__Garden__c garden1 = new CAMPX__Garden__c(Name = 'GardenOne');
        CAMPX__Garden__c garden2 = new CAMPX__Garden__c(Name = 'GardenTwo');

        listOfGardens.add(garden1);
        listOfGardens.add(garden2);
        insert listOfGardens;

        CAMPX__Plant__c newPlant = new CAMPX__Plant__c(Name = 'FirstPlant', CAMPX__Garden__c = garden1.id);
        insert newPlant;
        newPlant.CAMPX__Garden__c = garden2.id;
        update newPlant;

        List <CAMPX__Garden__c> updatedGardens =   [
                                            SELECT  id,
                                                    Name,
                                                    CAMPX__Total_Plant_Count__c
                                            FROM    CAMPX__Garden__c
                                            WHERE Name IN ('GardenOne', 'GardenTwo')
                                            ORDER BY createdDate DESC
                                            ];
        System.debug('List of updated gardens : '+updatedGardens);
                                            
        Assert.areEqual(0, updatedGardens.get(0).CAMPX__Total_Plant_Count__c, 'GardenOne should have 0 plant in total count');
        Assert.areEqual(1, updatedGardens.get(1).CAMPX__Total_Plant_Count__c, 'GardenTwo should have at least 1 plant in total count');

    }

    @isTest
    static void insertAndDeletePlantWithGarden() {

        CAMPX__Garden__c garden3 = new CAMPX__Garden__c(Name = 'GardenThree');
        insert garden3;

        CAMPX__Plant__c newPlant = new CAMPX__Plant__c(Name = 'FirstPlant', CAMPX__Garden__c = garden3.id);
        insert newPlant;
        CAMPX__Garden__c updatedGarden3 =   [
                                            SELECT  id,
                                                    CAMPX__Total_Plant_Count__c
                                            FROM    CAMPX__Garden__c
                                            WHERE Name = 'GardenThree'
                                            LIMIT   1
                                            ];
        Assert.areEqual(1, updatedGarden3.CAMPX__Total_Plant_Count__c, 'GardenThree should have at least 1 plant in total count');
        List<CAMPX__Plant__c> plantsToDelete = [SELECT id FROM CAMPX__Plant__c];
        delete plantsToDelete;
        CAMPX__Garden__c updatedGarden4 =   [
                                            SELECT  id,
                                                    CAMPX__Total_Plant_Count__c
                                            FROM    CAMPX__Garden__c
                                            WHERE   Name = 'GardenThree'
                                            LIMIT   1
                                            ];
        Assert.areEqual(0, updatedGarden4.CAMPX__Total_Plant_Count__c, 'GardenThree should have 0 plant in total count');
    }


    @isTest
    static void updatePlantToNoGarden() {
        CAMPX__Garden__c garden5 = new CAMPX__Garden__c(Name = 'GardenFive');
        insert garden5;

        CAMPX__Plant__c newPlant = new CAMPX__Plant__c(Name = 'FirstPlant', CAMPX__Garden__c = garden5.id);
        insert newPlant;

        newPlant.CAMPX__Garden__c = null;
        update newPlant;

        CAMPX__Garden__c updatedGarden5 =   [
                                            SELECT  id,
                                                    CAMPX__Total_Plant_Count__c
                                            FROM    CAMPX__Garden__c
                                            WHERE   Name = 'GardenFive'
                                            LIMIT   1
                                            ];
        Assert.areEqual(0, updatedGarden5.CAMPX__Total_Plant_Count__c, 'GardenFive should have 0 plant in total count');
    }

    @isTest
    static void deletePlant() {
        CAMPX__Garden__c garden6 = new CAMPX__Garden__c(Name = 'GardenSix');
        insert garden6;

        CAMPX__Plant__c newPlant = new CAMPX__Plant__c(Name = 'FirstPlant', CAMPX__Garden__c = garden6.id);
        insert newPlant;
        delete newPlant;

        CAMPX__Garden__c updatedGarden6 =   [
                                            SELECT  id,
                                                    CAMPX__Total_Plant_Count__c
                                            FROM    CAMPX__Garden__c
                                            WHERE   Name = 'GardenSix'
                                            LIMIT   1
                                            ];
        Assert.areEqual(0, updatedGarden6.CAMPX__Total_Plant_Count__c, 'GardenSix should have 0 plant in total count');
    }

    @isTest
    static void insertUnhealthyPlantWithGarden() {
        CAMPX__Garden__c gardenA = new CAMPX__Garden__c(Name = 'Jardin');
        insert gardenA;

        CAMPX__Plant__c unhealthyPlant = new CAMPX__Plant__c(Name = 'Plante Malade', CAMPX__Status__c = 'Sick' , CAMPX__Garden__c = gardenA.id);
        insert unhealthyPlant;

        CAMPX__Garden__c insertedGarden =   [
                                            SELECT  id,
                                                    CAMPX__Total_Unhealthy_Plant_Count__c
                                            FROM    CAMPX__Garden__c
                                            LIMIT   1
                                            ];
        Assert.areEqual(1, insertedGarden.CAMPX__Total_Unhealthy_Plant_Count__c, 'GardenA should have at least 1 unhealthy plant in total count');
    }

    @isTest
    static void updateUnhealthyPlantWithGarden() {
        CAMPX__Garden__c gardenA = new CAMPX__Garden__c(Name = 'Jardin');
        insert gardenA;

        CAMPX__Plant__c unhealthyPlant = new CAMPX__Plant__c(Name = 'Plante Malade', CAMPX__Status__c = 'Healthy' , CAMPX__Garden__c = gardenA.id);
        insert unhealthyPlant;

        CAMPX__Garden__c insertedGarden =   [
                                            SELECT  id,
                                                    CAMPX__Total_Unhealthy_Plant_Count__c
                                            FROM    CAMPX__Garden__c
                                            LIMIT   1
                                            ];
        
        Assert.areEqual(0, insertedGarden.CAMPX__Total_Unhealthy_Plant_Count__c, 'GardenA should have at no unhealthy plant in total count');

        unhealthyPlant.CAMPX__Status__c = 'Wilting';
        update unhealthyPlant;

        CAMPX__Garden__c updatedGarden =   [
            SELECT  id,
                    CAMPX__Total_Unhealthy_Plant_Count__c
            FROM    CAMPX__Garden__c
            LIMIT   1
            ];

        Assert.areEqual(1, updatedGarden.CAMPX__Total_Unhealthy_Plant_Count__c, 'GardenA should have at least 1 unhealthy plant in total count');
    }
}