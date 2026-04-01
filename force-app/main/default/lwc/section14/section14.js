import { LightningElement, wire, track } from 'lwc';
import getAllObjects from '@salesforce/apex/ObjectSchemaController.getAllObjects';
import getObjectFields from '@salesforce/apex/ObjectSchemaController.getObjectFields';
import executeSOQL from '@salesforce/apex/ObjectSchemaController.executeSOQL';
import SoqlLabel from '@salesforce/label/c.SoqlLabel';
import SoqlBodyLabel from '@salesforce/label/c.SoqlBodyLabel';
import ChooseAnObjectLabel from '@salesforce/label/c.ChooseAnObjectLabel';
import EnterTheNameLabel from '@salesforce/label/c.EnterTheNameLabel';
import SelectFieldsLabel from '@salesforce/label/c.SelectFieldsLabel';
import AvailableLable from '@salesforce/label/c.AvailableLable';
import SelectedLable from '@salesforce/label/c.SelectedLable';
import AddFilterLabel from '@salesforce/label/c.AddFilterLabel';
import FieldLabel from '@salesforce/label/c.FieldLabel';
import OperatorLabel from '@salesforce/label/c.OperatorLabel';
import ValueLabel from '@salesforce/label/c.ValueLabel';
import EnterLimitLabel from '@salesforce/label/c.EnterLimitLabel';
import EnterOffsetLabel from '@salesforce/label/c.EnterOffsetLabel';
import GenerateQueryLabel from '@salesforce/label/c.GenerateQueryLabel';
import EditGeneratedSOQLLabel from '@salesforce/label/c.EditGeneratedSOQLLabel';
import ExecuteQueryLabel from '@salesforce/label/c.ExecuteQueryLabel';
import NoRecordsLabel from '@salesforce/label/c.NoRecordsLabel';


export default class Section14 extends LightningElement {
    @track objectOptions = [];
    @track fieldOptions = [];
    finalQuery = '';
    whereField = '';
    whereOperator = '=';
    whereValue = '';
    limitValue = 0;
    offsetValue = 0;
    @track queryData = [];
    @track columns = [];
    isInvalidLimit = false;
    emptyMessage = false;
    selectedObject = '';
    @track selectedFields = [];
    labels = {
        SoqlLabel,
        SoqlBodyLabel,
        ChooseAnObjectLabel,
        EnterTheNameLabel,
        SelectFieldsLabel,
        AvailableLable,
        SelectedLable,
        AddFilterLabel,
        FieldLabel,
        OperatorLabel,
        ValueLabel,
        EnterLimitLabel,
        EnterOffsetLabel,
        GenerateQueryLabel,
        EditGeneratedSOQLLabel,
        ExecuteQueryLabel,
        NoRecordsLabel,
    };

    get operatorOptions() {
        return [
            { label: 'Equals', value: '=' },
            { label: 'Not equal to', value: '!=' },
            { label: 'Greater than', value: '>' },
            { label: 'Less than', value: '<' },
            { label: 'Contains', value: 'LIKE' }
        ];
    }

    @wire (getAllObjects)
    wiredObjectList({error, data}){
        if(data){
            this.objectOptions = [...data].sort((a,b) =>
                a.label.localeCompare(b.label)
            );
        if(error){
            console.log(error);
            }
        }
    }

    handleChangeObject(event){
        this.selectedObject = event.detail.value;
        this.fieldOptions = [];
        getObjectFields({objectName: this.selectedObject})
        .then(result => {
            this.fieldOptions = [...result].sort((a, b) => a.label.localeCompare(b.label));
        })
        .catch(error => {
            console.error('Error fetching fields:', error);
        });
    }

    handleFieldChange(event) {
        this.selectedFields = event.detail.value;
    }

    handleWhereFieldChange(event) { this.whereField = event.detail.value; }
    handleOperatorChange(event) { this.whereOperator = event.detail.value; }
    handleWhereValueChange(event) { this.whereValue = event.detail.value; }

    handleLimitChange(event) {
        this.limitValue = event.detail.value;
    }

    handleOffsetChange(event) { this.offsetValue = event.detail.value; }

    handleGenerate() {
        const fields = this.selectedFields.join(', ');
        let query = `SELECT ${fields} FROM ${this.selectedObject}`;
        if (this.whereField && this.whereValue) {
            let formattedValue = this.whereOperator === 'LIKE' ? `'%${this.whereValue}%'` : `'${this.whereValue}'`;
            query += ` WHERE ${this.whereField} ${this.whereOperator} ${formattedValue}`;
        }
        if (this.limitValue && Number(this.limitValue) > 0) {
            query += ` LIMIT ${this.limitValue}`;
        }
        if (this.offsetValue && Number(this.offsetValue) > 0) {
            query += ` OFFSET ${this.offsetValue}`;
        }
        this.finalQuery = query;
    }

    get isFieldSelected() {
        return this.selectedFields && this.selectedFields.length > 0;
    }

    get isWhereConditionSelected() {
        return this.whereField && this.whereOperator && this.whereValue;
    }

    get isLimitAndOffsetSelected() {
        return this.limitValue && this.offsetValue;
    }

    handleQueryEdit(event){
        this.finalQuery = event.target.value;
    }

    handleExecute(){
        executeSOQL({query: this.finalQuery})
        .then(result => {
                this.queryData = result;
                if(result.length === 0){
                    this.emptyMessage = true;
                }
            })
        .catch(error => {
            this.queryData = [];
            console.error('SOQL Error:', error.body.message);
            this.emptyMessage = true;
        });
    }
}