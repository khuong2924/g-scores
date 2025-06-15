-- Tạo bảng scores nếu chưa tồn tại
CREATE TABLE IF NOT EXISTS scores (
    id SERIAL PRIMARY KEY,
    sbd VARCHAR(20) NOT NULL,
    toan DECIMAL(4,2),
    ngu_van DECIMAL(4,2),
    ngoai_ngu DECIMAL(4,2),
    vat_li DECIMAL(4,2),
    hoa_hoc DECIMAL(4,2),
    sinh_hoc DECIMAL(4,2),
    lich_su DECIMAL(4,2),
    dia_li DECIMAL(4,2),
    gdcd DECIMAL(4,2),
    ma_ngoai_ngu VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tạo index cho sbd
CREATE INDEX IF NOT EXISTS idx_scores_sbd ON scores(sbd);

-- Import dữ liệu từ file CSV
\copy scores(sbd, toan, ngu_van, ngoai_ngu, vat_li, hoa_hoc, sinh_hoc, lich_su, dia_li, gdcd, ma_ngoai_ngu) FROM '/tmp/csv_imports/import_1749912561.csv' WITH (FORMAT csv, HEADER true, NULL '');