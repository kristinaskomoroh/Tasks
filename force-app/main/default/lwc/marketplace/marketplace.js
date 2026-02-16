import { LightningElement } from 'lwc';

export default class Marketplace extends LightningElement {
    isJoinModalOpen = false;
    isSignModalOpen = false;

    openModalJoin() {
        this.isJoinModalOpen = true;
    }

    openModalSign() {
        this.isSignModalOpen = true;
    }

    closeJoinModal() {
        this.isJoinModalOpen = false;
    }

    closeSignModal(){
        this.isSignModalOpen = false;
    }
}