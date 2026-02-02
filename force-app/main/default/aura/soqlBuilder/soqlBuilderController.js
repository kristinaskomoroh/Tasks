({
    doInit : function(component, event, helper) {
        helper.fetchObjects(component);
    },

    handleObjectChange : function(component, event, helper) {
        let objectName = component.get("v.selectedObject");
        helper.fetchFields(component, objectName);
    },

    handleFieldChange : function(component, event, helper){
        let selectedFields = component.get("v.selectedFields");
        if(selectedFields.length > 0){
            component.set("v.isFieldSelected", true);
        }else {
            component.set("v.isFieldSelected", false);
        }
    },

    handleGenerate : function(component, event, helper){
        let query = helper.buildQueryString(component);
        if(query){
            component.set("v.finalQuery", query);
        }else {
            alert("Please select an object and at least one field.");
        }
    },

    handleWhereFieldChange : function(component, event, helper){
        let whereField = component.get("v.whereField");
    },

     handleOperatorChange : function(component, event, helper){
        let whereOperator = component.get("v.whereOperator");
    },

    handleWhereValueChange : function(component, event, helper){
        let whereValue = component.get("v.whereValue");
        if(whereValue){
            component.set("v.isWhereConditionSelected", true);
        }
        else{
            component.set("v.isWhereValueSelected", false);
        }
    },


    handleLimitChange : function(component, event, helper){
        let limitValue = component.get("v.limitValue");
    },

    handleOffsetChange : function(component, event, helper){
        let offsetValue = component.get("v.offsetValue");
        if(offsetValue){
            component.set("v.isLimitAndOffsetSelected", true);
        }
        else{
            component.set("v.isLimitAndOffsetSelected", false);
        }
    },

    handleQueryEdit : function(component, event, helper){
        let finalQuery = component.get("v.finalQuery");
    },

    handleExecute : function(component, event, helper){
        let finalQuery = component.get("v.finalQuery");
        if(finalQuery){
            helper.executeQuery(component, finalQuery);
        }else {
            alert("Please generate a query first.");
        }
    }

})