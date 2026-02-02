({
    updatePagedRecords : function(component) {
        let data = component.get("v.data");
        let currentPage = component.get("v.currentPage");
        let pageSize = component.get("v.pageSize");
        let startIndex = (currentPage - 1) * pageSize;
        let endIndex = startIndex + pageSize;
        let visibleData = data.slice(startIndex, endIndex);
        component.set("v.visibleData", visibleData);
    },

    buildColumns : function(component) {
        let columns = Object.keys(firstRecord)
            .filter(key => key !== 'attributes')
            .map(key => {
                return { 
                    label: key, 
                    fieldName: key, 
                    type: 'text', 
                    sortable: true 
                };
            });
            
        component.set("v.columns", columns);
    },

    sortData : function(component, fieldName, sortedDirection){
        let data = component.get("v.data");
        let reverse = sortedDirection !== 'asc';

        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);
        this.updatePagedRecords(component);
    },

    sortBy : function(field, reverse, primer){
        let key = primer ? function(x) { return primer(x[field]) } : function(x) { return x[field] };
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
        a = key(a) ? key(a) : '';
        b = key(b) ? key(b) : '';
        return reverse * ((a > b) - (b > a));
    }
    }
})