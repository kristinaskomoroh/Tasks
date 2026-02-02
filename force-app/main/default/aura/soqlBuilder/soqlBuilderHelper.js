({
    fetchObjects : function(component){
        let action = component.get("c.getAllObjects");
        action.setParams({
            objectName : component.get("v.selectedObject")
        })
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let allObjects = response.getReturnValue();
                allObjects.sort((a, b) => a.label.localeCompare(b.label));
                component.set("v.objectOptions", allObjects);
            } else {
                console.error("Error fetching objects");
            }
        });
        $A.enqueueAction(action);
    },

    fetchFields : function(component, objectName){
        let action = component.get("c.getObjectFields");
        action.setParams({
            objectName : objectName
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.fieldOptions", response.getReturnValue());
            } else {
                console.error("Error fetching fields");
            }
        });
        $A.enqueueAction(action);
    },
    
    buildQueryString : function(component) {
        let obj = component.get("v.selectedObject");
        let fields = component.get("v.selectedFields");
        let whereF = component.get("v.whereField");
        let whereOp = component.get("v.whereOperator");
        let whereVal = component.get("v.whereValue");
        let limitVal = component.get("v.limitValue");
        let offsetVal = component.get("v.offsetValue");

        if(!obj || fields.lenght === 0) return ""

        let query = " SELECT " + fields.join(",") + " FROM " + obj;

        if(whereF && whereOp && whereVal){
            let formattedVal;
            if (whereOp !== 'LIKE' && !isNaN(whereVal) && whereVal.trim() !== "") {
            formattedVal = whereVal;
            } else if (whereOp === 'LIKE') {
            formattedVal = "'%" + whereVal + "%'";
            } else {
            formattedVal = "'" + whereVal + "'";
        }
            query += " WHERE " + whereF + " " + whereOp + " " + formattedVal;
        }

        if(limitVal !== "" && limitVal !== null){
            query += " LIMIT " + limitVal;
        }

        if(offsetVal !== "" && offsetVal !== null){
            query += " OFFSET " + offsetVal;
        }

        return query;
        
    },

    executeQuery : function(component, query){
        let action = component.get("c.executeSOQL");
        action.setParams({
            query : query
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.queryData", response.getReturnValue());
            } else {
                console.error("Error executing query");
            }
        });
        $A.enqueueAction(action);
    }
})