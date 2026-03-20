import { LightningElement, api } from 'lwc';

export default class CoinSimulator extends LightningElement {

    @api loading = false;
    @api result = '';

    handleFlip(){
        this.loading = true;
        setTimeout(() => {this.result = Math.random() < 0.5 ? 'Heads' : 'Tails';  this.loading = false; setTimeout(() => {this.result = '';}, 2000);}, 2000);
    }
}