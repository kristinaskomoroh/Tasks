import { LightningElement } from 'lwc';
import CategoriesLabel from '@salesforce/label/c.CategoriesLabel';
import ElectronicsLabel from '@salesforce/label/c.ElectronicsLabel';
import ClothesLabel from '@salesforce/label/c.ClothesLabel';
import HouseAndGardenLabel from '@salesforce/label/c.HouseAndGardenLabel';
import AccessoriesLabel from '@salesforce/label/c.AccessoriesLabel';
import PetsLabel from '@salesforce/label/c.PetsLabel';
import SportLabel from '@salesforce/label/c.SportLabel';
import BooksLabel from '@salesforce/label/c.BooksLabel';
import ArtLabel from '@salesforce/label/c.ArtLabel';
import CosmeticsLabel from '@salesforce/label/c.CosmeticsLabel';
import CarsLabel from '@salesforce/label/c.CarsLabel';

export default class Categories extends LightningElement {

    labels = {
        CategoriesLabel,
        ElectronicsLabel,
        ClothesLabel,
        HouseAndGardenLabel,
        AccessoriesLabel,
        PetsLabel,
        SportLabel,
        BooksLabel,
        ArtLabel,
        CosmeticsLabel,
        CarsLabel
    };
}