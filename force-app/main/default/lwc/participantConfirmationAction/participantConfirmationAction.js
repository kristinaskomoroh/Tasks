import { LightningElement, api} from 'lwc';
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningConfirm from 'lightning/confirm';
import getOrder from '@salesforce/apex/OrderController.getOrder';

import SaveLabel from '@salesforce/label/c.SaveLabel';
import CancelLabel from '@salesforce/label/c.CancelLabel';
import DebitorNumberMessage from '@salesforce/label/c.DebitorNumberMessage';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import ConfirmTheme from '@salesforce/label/c.ConfirmTheme';
import FormMessage from '@salesforce/label/c.FormMessage';
import InformationalLabel from '@salesforce/label/c.InformationalLabel';
import InformationalTheme from '@salesforce/label/c.InformationalTheme';
import Participant_status_message from '@salesforce/label/c.Participant_status_message';
import SuccessLabel from '@salesforce/label/c.SuccessLabel';
import ToastMessageStatusLabel from '@salesforce/label/c.ToastMessageStatusLabel';
import ErrorLabel from '@salesforce/label/c.ErrorLabel';
import ToastMessageFormLabel from '@salesforce/label/c.ToastMessageFormLabel';
import ToastMessageNumberLabel from '@salesforce/label/c.ToastMessageNumberLabel';
import FirstModalLabel from '@salesforce/label/c.FirstModalLabel';
import EnterNumberLabel from '@salesforce/label/c.EnterNumberLabel';
import OrderNameLabel from '@salesforce/label/c.OrderNameLabel';
import ErrorMessageLabel from '@salesforce/label/c.ErrorMessageLabel';




export default class ParticipantConfirmationAction extends LightningElement {
    _recordId;
    @api objectApiName;
    orderName;
    debitorNum;
    contactId;
    enteredNumber = '';
    entryToUpdate = null;
    isEditingMode = false;
    isLoading = true;
    wiredData;

    labels = {
        SaveLabel,
        CancelLabel,
        DebitorNumberMessage,
        ConfirmLabel,
        ConfirmTheme,
        FormMessage,
        InformationalLabel,
        InformationalTheme,
        Participant_status_message,
        SuccessLabel,
        ToastMessageStatusLabel,
        ErrorLabel,
        ToastMessageFormLabel,
        ToastMessageNumberLabel,
        FirstModalLabel,
        EnterNumberLabel,
        OrderNameLabel,
        ErrorMessageLabel
    }

    @api
    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.loadData();
        }
    }

    get recordId() {
        return this._recordId;
    }

    loadData() {
        getOrder({recordId: this.recordId})
            .then(result => {
                this.wiredData = result;
                this.entryToUpdate = this.wiredData.order?.Ticket__c;
                this.debitorNum = this.wiredData.order?.Applicant__r?.Debitor_number__c;
                this.contactId = this.wiredData.order?.Applicant__c;
                this.orderName = this.wiredData.order?.Name;
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    get isConfirmStep() {
        return this.wiredData?.isEntryPreregistered;
    }

    get isEnterNumberStep() {
        return !this.debitorNum && this.wiredData?.isEntryFixed;
    }

    get isEditFormStep() {
        return !!this.debitorNum && this.wiredData?.isEntryFixed;
    }

    get orderUrl(){
        return `/lightning/r/Order/${this.recordId}/view`;
    }

    async handleConfirm(){
        try{
            const result = await LightningConfirm.open({
                message: this.labels.Participant_status_message,
                label: this.labels.InformationalLabel,
                theme: this.labels.InformationalTheme,
                });
            if(!result) return;
            await this.updateEntryStatus();
        }catch(error){
            this.handleError(error);
        }finally{
            this.loadData();
        }
    }

    async updateEntryStatus(){
        if(!this.entryToUpdate){
            this.showToast(this.labels.ErrorLabel, this.labels.ErrorMessageLabel, this.labels.ErrorLabel);
            return;
        }
        const fields = {}
        fields['Id'] = this.entryToUpdate;
        fields['Status__c'] = this.wiredData?.entryChangedStatus;
        const recordInput = {fields};
        await updateRecord(recordInput);
        this.showToast(this.labels.SuccessLabel, this.labels.ToastMessageStatusLabel, this.labels.SuccessLabel);
    }

    handleContactSuccess(event){
        const updatedFields = event.detail.fields;
        this.debitorNum = updatedFields.Debitor_number__c.value;
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleInputNumber(event){
        this.enteredNumber = event.target.value;
    }

    async handleForm(){
        try{
            const confirmMessage = await LightningConfirm.open({
                message: this.labels.FormMessage,
                label: this.labels.ConfirmLabel,
                theme: this.labels.ConfirmTheme,
            });
            if(confirmMessage){
                const fieldsOrder = {Id: this.recordId, Ticket_status__c: this.wiredData?.orderChangedStatus};
                await updateRecord({fields: fieldsOrder}),
                this.showToast(this.labels.SuccessLabel, this.labels.ToastMessageFormLabel, this.labels.SuccessLabel);
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        }catch(error){
            this.handleError(error);
        }
    }

    async handleNumber(){
        try{
            const confirmMessage = await LightningConfirm.open({
                message: this.labels.DebitorNumberMessage,
                label: this.labels.ConfirmLabel,
                theme: this.labels.ConfirmTheme,
            });
            if(confirmMessage){
                const fields = {}
                fields['Id'] = this.contactId;
                fields['Debitor_number__c'] = this.enteredNumber;
                const recordInput = {fields};
                await updateRecord(recordInput);
                this.showToast(this.labels.SuccessLabel, this.labels.ToastMessageNumberLabel, this.labels.SuccessLabel);
            }
        }catch(error){
            this.handleError(error);
        }finally{
            this.loadData();
        }
    }

    enableEditMode(){
        this.isEditingMode = true;
    }

    handleFormLoad(){
        this.isLoading = false;
    }

    handleAction() {
        if(this.isConfirmStep) this.handleConfirm();
        if(this.isEditFormStep) this.handleForm();
        if(this.isEnterNumberStep) this.handleNumber();
    }

    handleError(error){
        const errorMsg = error?.body?.output?.errors?.[0]?.message
                      || error?.body?.message
                      || error?.message
                      || this.labels.ErrorMessageLabel;
        this.showToast(this.labels.ErrorLabel, errorMsg, this.labels.ErrorLabel);
    }

    confirmEdit() {
        const form = this.template.querySelector('.my-form');
        if (form) {
            form.submit();
        }
        this.isEditingMode = false;
    }

    cancelEdit() {
        const inputField = this.template.querySelector('.debitor-input');
        if(inputField){
            inputField.reset();
        }
        this.isEditingMode = false;
    }
}