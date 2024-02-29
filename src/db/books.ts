import mongoose from 'mongoose';

export const CategorySchema = new mongoose.Schema({
    name: { type: String, required: true },
});

const RecordSchema = new mongoose.Schema({
    categoryId: { type: String, required: true },
    date: { type: Date, required: true },
    amount: { type: Number, required: true },
    remark: { type: String },
});

export const BookSchema = new mongoose.Schema({
    title: { type: String, required: true },
    categories: { type: [CategorySchema], required: true },
    records: { type: [RecordSchema], default: [], select: false},
});

export const CategoryModel = mongoose.model('Category', CategorySchema);

export const getCategories = () => CategoryModel.find();
