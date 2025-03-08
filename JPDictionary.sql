CREATE DATABASE JPDictionary;
GO

USE JPDictionary;
GO

-- Bảng lưu trữ phân quyền (admin, user, guest)
CREATE TABLE roles (
    id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(20) UNIQUE NOT NULL
);

-- Bảng lưu trữ người dùng và liên kết với bảng roles
CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) UNIQUE NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    role_id INT DEFAULT 2,  -- Mặc định là user
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE SET DEFAULT
);

-- Bảng lưu trữ từ loại (noun, verb, adjective, ...)
CREATE TABLE parts_of_speech (
    id INT IDENTITY(1,1) PRIMARY KEY,
    pos_name NVARCHAR(50) UNIQUE NOT NULL
);

-- Bảng lưu trữ từ vựng
CREATE TABLE words (
    id INT IDENTITY(1,1) PRIMARY KEY,
    word NVARCHAR(255) NOT NULL,
    reading NVARCHAR(255),
    meaning NVARCHAR(MAX) NOT NULL,
    part_of_speech_id INT,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (part_of_speech_id) REFERENCES parts_of_speech(id) ON DELETE SET NULL
);

-- Bảng lưu trữ câu ví dụ
CREATE TABLE examples (
    id INT IDENTITY(1,1) PRIMARY KEY,
    word_id INT,
    sentence_jp NVARCHAR(MAX) NOT NULL,
    sentence_vi NVARCHAR(MAX) NOT NULL,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);

-- Bảng lưu trữ Kanji
CREATE TABLE kanji (
    id INT IDENTITY(1,1) PRIMARY KEY,
    kanji NCHAR(1) NOT NULL UNIQUE,
    onyomi NVARCHAR(255),
    kunyomi NVARCHAR(255),
    meaning NVARCHAR(MAX) NOT NULL,
    strokes INT,
    jlpt_level INT,
    created_at DATETIME DEFAULT GETDATE()
);

-- Liên kết từ vựng với Kanji
CREATE TABLE word_kanji (
    word_id INT,
    kanji_id INT,
    PRIMARY KEY (word_id, kanji_id),
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE,
    FOREIGN KEY (kanji_id) REFERENCES kanji(id) ON DELETE CASCADE
);

-- Bảng lưu trữ bộ flashcard của người dùng
CREATE TABLE flashcards (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    name NVARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Liên kết từ vựng với bộ flashcard
CREATE TABLE flashcard_words (
    flashcard_id INT,
    word_id INT,
    PRIMARY KEY (flashcard_id, word_id),
    FOREIGN KEY (flashcard_id) REFERENCES flashcards(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);

-- Bảng lưu trữ bài luyện tập ghi nhớ từ vựng
CREATE TABLE quizzes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    word_id INT,
    score INT DEFAULT 0,  -- Mặc định điểm là 0
    question_type NVARCHAR(10) CHECK (question_type IN ('meaning', 'reading', 'kanji')),
    user_answer NVARCHAR(255),
    is_correct BIT,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);

-- Bảng lưu trữ tiến trình học của người dùng
CREATE TABLE study_progress (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    word_id INT,
    last_reviewed DATETIME DEFAULT GETDATE(),
    review_count INT DEFAULT 0,
    proficiency_level NVARCHAR(10) CHECK (proficiency_level IN ('new', 'learning', 'mastered')) DEFAULT 'new',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);

-- Bảng phân quyền chi tiết
CREATE TABLE permissions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    role_id INT,
    permission NVARCHAR(100) NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);
