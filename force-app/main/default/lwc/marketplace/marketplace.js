import { LightningElement } from 'lwc';

export default class Marketplace extends LightningElement {
    isJoinModalOpen = false;
    isSignModalOpen = false;
    openModalJoin() {
        this.isJoinModalOpen = true; 
    }
    closeJoinModal() {
        this.isJoinModalOpen = false;
    }
    openModalSign(){
        this.isSignModalOpen = true;
    }
    closeSignModal(){
        this.isSignModalOpen = false;
    }
}