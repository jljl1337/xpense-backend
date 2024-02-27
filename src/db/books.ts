import mongoose from 'mongoose';

export const CategorySchema = new mongoose.Schema({
    name: { type: String, required: true },
});

const RecordSchema = new mongoose.Schema({
    category_id: { type: String, required: true },
    date: { type: Date, default: Date.now },
    remark: { type: String, required: true },
});

export const BookSchema = new mongoose.Schema({
    title: { type: String, required: true },
    categories: { type: [CategorySchema], required: true },
    records: { type: [RecordSchema], default: [], select: false},
});

export const CategoryModel = mongoose.model('Category', CategorySchema);

export const getCategories = () => CategoryModel.find();
