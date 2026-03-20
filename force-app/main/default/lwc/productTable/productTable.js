import { LightningElement, track } from 'lwc';
import getProducts from '@salesforce/apex/ProductTableController.getProducts';
import createProduct from '@salesforce/apex/ProductTableController.createProduct';
import deleteProduct from '@salesforce/apex/ProductTableController.deleteProduct';
import updateProduct from '@salesforce/apex/ProductTableController.updateProduct';



export default class ProductTable extends LightningElement {
    @track products = [];

    isModalOpen = false;
    isDeleteModalOpen = false;
    isEditModalOpen = false;
    isLoading = false;

    searchText = '';
    searchTimeout;

    pagedProducts = [];
    newProduct = {};
    editProduct = {};
    productIdToDelete = null;

    pageSize = 5;
    currentPage = 1;
    totalPages = 1;

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }


    async connectedCallback() {
        this.isLoading = true;
        await this.loadProducts(this.searchText);
        this.isLoading = false;
    }

    openModal() {
        this.newProduct = {};
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    openDeleteModal(event) {
        this.productIdToDelete = event.currentTarget.dataset.id;
        this.isDeleteModalOpen = true;
    }

    canselDelete(){
        this.isDeleteModalOpen = false;
        this.productIdToDelete = null;
    }

    openEditModal(event) {
        const id = event.currentTarget.dataset.id;
        this.editProduct = { ...this.products.find(p => p.Id === id) };
        this.isEditModalOpen = true;
    }

    closeEditModal() {
        this.isEditModalOpen = false;
    }


    handleInputChange(event) {
        this.newProduct[event.target.dataset.field] = event.target.value;
    }

    handleEditInputChange(event) {
        this.editProduct[event.target.dataset.field] = event.target.value;
    }

    handleSearch(event) {
        this.searchText = event.target.value;
        clearTimeout(this.searchTimeout);

        this.searchTimeout = setTimeout(async () => {
        await this.loadProducts(this.searchText);
    }, 300);
}

    validateForm(){
        let isValid = true;
        const inputs = this.template.querySelectorAll('lightning-input');

        inputs.forEach(input => {
            input.reportValidity();


            if (input.required && !input.value) {
                isValid = false;
            }
    if ((input.dataset.field === 'UnitPrice__c' && input.dataset.field === 'UnitsAvailable__c') &&
                (input.value === '' || Number(input.value) <= 0)) {
                input.setCustomValidity('Value must be greater than 0');
                isValid = false;
            }
        });
        return isValid;
    }

    async confirmDelete() {
        if (!this.productIdToDelete) return;
        this.products = await deleteProduct({ productId: this.productIdToDelete });
        this.updatePagedProducts();
        this.canselDelete();
    }

    async EditProduct() {
        if (!this.validateForm()) return;
        this.products = await updateProduct({ product: this.editProduct });
        this.updatePagedProducts();
        this.closeEditModal();
    }

    async saveProduct() {
        if (!this.validateForm()) return;
        this.products = await createProduct({ product: this.newProduct });
        this.updatePagedProducts();
        this.closeModal();
    }

    async loadProducts(searchText) {
        this.products = await getProducts({ searchText });
        this.totalPages = Math.ceil(this.products.length / this.pageSize);
        this.currentPage = 1;
        this.updatePagedProducts();
    }

    updatePagedProducts() {
        const size = Number(this.pageSize);
        const startIndex = (this.currentPage - 1) * size;
        const endIndex = startIndex + size;
        this.pagedProducts = [...this.products.slice(startIndex, endIndex)];
    }

    nextPage() {
        if (!this.isLastPage) {
            this.currentPage++;
            this.updatePagedProducts();
        }
    }

    prevPage() {
        if (!this.isFirstPage) {
            this.currentPage--;
            this.updatePagedProducts();
        }
    }

    get pageSizeOptions() {
    return [
        { label: '1', value: '1' },
        { label: '2', value: '2' },
        { label: '3', value: '3' },
        { label: '4', value: '4' },
        { label: '5', value: '5' },
    ];
    }

    handlePageSizeChange(event) {
        this.pageSize = event.detail.value;
        const numericValue = Number(this.pageSize);
        this.totalPages = Math.ceil(this.products.length / numericValue);
        this.currentPage = 1;
        this.updatePagedProducts();
    }

    handleJumpToPage(event) {
        const page = parseInt(event.target.value, 10);
        this.totalPages = Math.ceil(this.products.length / this.pageSize);
        if (page >= 1 && page <= this.totalPages) {
            this.currentPage = page;
            this.updatePagedProducts();
        }
        else if(page > this.totalPages){
            this.currentPage = this.totalPages;
            this.updatePagedProducts();
        }
    }
}