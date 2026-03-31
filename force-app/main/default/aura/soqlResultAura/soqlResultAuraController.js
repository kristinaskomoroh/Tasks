({
    handleDataChange : function(component, event, helper) {
        let value = component.get("v.data")
        if(value && value.length > 0){
            helper.buildColumns(component, value[0]);
            let pageSize = component.get("v.pageSize");
            let totalPages = Math.ceil(value.length / pageSize);
            component.set("v.totalPages", totalPages);
            component.set("v.currentPage", 1);
            helper.updatePagedRecords(component);
        }else {
            component.set("v.visibleData", []);
            component.set("v.totalPages", 1);
        }
    },

    prevPage : function(component, event, helper) {
        let currentPage = component.get("v.currentPage");
        if(currentPage > 1) {
            component.set("v.currentPage", currentPage - 1);
            helper.updatePagedRecords(component);
        }
    },

    nextPage : function(component, event, helper) {
        let currentPage = component.get("v.currentPage");
        let totalPages = component.get("v.totalPages");
        if(currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.updatePagedRecords(component);
        }
    },

    handleSort : function(component, event, helper){
        let fieldName = event.getParam('fieldName');
        let sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    }
})