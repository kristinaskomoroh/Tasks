import { LightningElement, api, track } from 'lwc';
import NextLabel from '@salesforce/label/c.NextLabel';
import PrevLabel from '@salesforce/label/c.PrevLabel';

export default class SoqlResult extends LightningElement {
    @api queryResult = '';
    @track visibleData = [];
    sortedBy;
    sortedDirection = 'asc';
    @track internalData = [];

    currentPage = 1;
    pageSize = 5;
    totalPages = 1;

    labels = {
        NextLabel,
        PrevLabel
    }

    @api
    get data() {
        return this.internalData;
    }

    set data(value) {
        if (value) {
            this.internalData = value;
            this.totalPages = Math.ceil(value.length / this.pageSize) || 1;
            this.currentPage = 1;
            this.updatePagedRecords();
        }
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    updatePagedRecords() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        this.visibleData = [...this.internalData.slice(startIndex, endIndex)];
    }

    nextPage() {
        if (!this.isLastPage) {
            this.currentPage++;
            this.updatePagedRecords();
        }
    }

    prevPage() {
        if (!this.isFirstPage) {
            this.currentPage--;
            this.updatePagedRecords();
        }
    }

    get columns() {
        if (this.data && this.data.length > 0) {
            return Object.keys(this.data[0]).map(key => {
                return { label: key, fieldName: key, sortable: true };
            });
        }
        return [];
    }

    handleSort(event){
        const {fieldName: sortedBy, sortDirection: sortedDirection} = event.detail;
        const cloneData = [...this.data];

        cloneData.sort((a, b) => {
            let valueA = a[sortedBy] ? a[sortedBy] : '';
            let valueB = b[sortedBy] ? b[sortedBy] : '';
            const reverse = sortedDirection === 'asc' ? 1 : -1;
            return reverse * (valueA > valueB ? 1 : -1);
        });
        this.data = cloneData;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortedDirection;
        this.updatePagedRecords();
    }
}