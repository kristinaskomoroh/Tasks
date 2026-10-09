import { LightningElement, api} from 'lwc';
import getBatchStatus from '@salesforce/apex/BatchProgressController.getBatchStatus';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import GenerateXMLFileLabel from '@salesforce/label/c.GenerateXMLFileLabel';
import PackagesProcessedLabel from '@salesforce/label/c.PackagesProcessedLabel';
import StatusLabel from '@salesforce/label/c.StatusLabel';
import GenerateFileErrorLabel from '@salesforce/label/c.GenerateFileErrorLabel';
import StatusFailedLabel from '@salesforce/label/c.StatusFailedLabel';
import StatusCompletedLabel from '@salesforce/label/c.StatusCompletedLabel';
import StatusAbortedLabel from '@salesforce/label/c.StatusAbortedLabel';

export default class BatchProgressTracker extends LightningElement {
    @api jobId;

    labels = {
        GenerateXMLFileLabel,
        PackagesProcessedLabel,
        StatusLabel,
        GenerateFileErrorLabel,
        StatusFailedLabel,
        StatusCompletedLabel,
        StatusAbortedLabel
    }

    status = '';
    processedItems = 0;
    totalItems = 0;
    errors = 0;
    progressPercentage = 0;

    pollingInterval;

    get isError() {
        return this.status === this.labels.StatusFailedLabel || this.errors > 0;
    }

    get pollingInterval() {
        if (this.totalItems === 0) return 0;
        return Math.floor((this.processedItems / this.totalItems) * 100);
    }

    connectedCallback() {
        this.pollingInterval = setInterval(() => {
            this.checkStatus();
        }, 2000);
    }

    disconnectedCallback() {
        clearInterval(this.pollingInterval);
    }

    checkStatus() {
        if (!this.jobId) return;
        getBatchStatus({ jobId: this.jobId })
            .then(result => {
                this.status = result.Status;
                this.processedItems = result.JobItemsProcessed;
                this.totalItems = result.TotalJobItems;
                this.errors = result.NumberOfErrors;
                if(this.totalItems > 0){
                    this.progressPercentage = Math.floor((this.processedItems / this.totalItems) * 100);
                }
                if (this.status === this.labels.StatusCompletedLabel) {
                    clearInterval(this.pollingInterval);
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                }
                else if (this.status === this.labels.StatusFailedLabel || this.status === this.labels.StatusAbortedLabel) {
                    clearInterval(this.pollingInterval);
                }
            })
            .catch(error => {
                clearInterval(this.pollingInterval);
            });
    }
}