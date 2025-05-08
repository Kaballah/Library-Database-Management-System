-- Library Management System Database
DROP DATABASE IF EXISTS library_management;

-- Create the database
CREATE DATABASE library_management;
USE library_management;

-- Create Members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15),
    address VARCHAR(255),
    date_of_birth DATE,
    membership_start_date DATE NOT NULL,
    membership_end_date DATE,
    status ENUM('Active', 'Inactive', 'Suspended') NOT NULL DEFAULT 'Active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Librarians table
CREATE TABLE librarians (
    librarian_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15),
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Publishers table
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone_number VARCHAR(15),
    address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    biography TEXT,
    birth_date DATE,
    nationality VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    publisher_id INT,
    publication_date DATE,
    edition VARCHAR(20),
    pages INT,
    language VARCHAR(30) DEFAULT 'English',
    summary TEXT,
    shelf_location VARCHAR(50),
    category_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
);

-- Create Book_Authors junction table
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    role ENUM('Primary', 'Co-author', 'Editor', 'Translator') DEFAULT 'Primary',
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Create Book_Copies table
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(30) UNIQUE NOT NULL,
    book_condition ENUM('New', 'Good', 'Fair', 'Poor', 'Damaged') NOT NULL DEFAULT 'New',
    acquisition_date DATE NOT NULL,
    price DECIMAL(10, 2),
    status ENUM('Available', 'Borrowed', 'Reserved', 'Lost', 'Under Repair') DEFAULT 'Available',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT
);

-- Create Borrowings table
CREATE TABLE borrowings (
    borrowing_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    librarian_id_checkout INT NOT NULL,
    librarian_id_return INT,
    borrow_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME NOT NULL,
    return_date DATETIME,
    fine_amount DECIMAL(10, 2) DEFAULT 0.00,
    fine_paid BOOLEAN DEFAULT FALSE,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost') DEFAULT 'Active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
    FOREIGN KEY (librarian_id_checkout) REFERENCES librarians(librarian_id) ON DELETE RESTRICT,
    FOREIGN KEY (librarian_id_return) REFERENCES librarians(librarian_id) ON DELETE RESTRICT
);

-- Create Reservations table
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATETIME NOT NULL,
    status ENUM('Pending', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Pending',
    fulfilled_date DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- Create Fines table
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    borrowing_id INT NOT NULL,
    member_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    issue_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_date DATETIME,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Online Payment') NULL,
    status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    librarian_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (borrowing_id) REFERENCES borrowings(borrowing_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
    FOREIGN KEY (librarian_id) REFERENCES librarians(librarian_id) ON DELETE SET NULL
);

-- Create Events table
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    location VARCHAR(100),
    max_attendees INT,
    event_type ENUM('Book Reading', 'Workshop', 'Author Visit', 'Children Program', 'Other') NOT NULL,
    librarian_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (librarian_id) REFERENCES librarians(librarian_id) ON DELETE SET NULL
);

-- Create Event_Registrations table
CREATE TABLE event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    member_id INT NOT NULL,
    registration_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered', 'Attended', 'Cancelled', 'No-show') DEFAULT 'Registered',
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- Create Book_Reviews table
CREATE TABLE book_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- Create Inventory_Log table
CREATE TABLE inventory_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    action ENUM('Added', 'Removed', 'Status Change', 'Condition Change') NOT NULL,
    action_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    previous_status VARCHAR(50),
    new_status VARCHAR(50),
    previous_condition VARCHAR(50),
    new_condition VARCHAR(50),
    notes TEXT,
    librarian_id INT,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE CASCADE,
    FOREIGN KEY (librarian_id) REFERENCES librarians(librarian_id) ON DELETE SET NULL
);

-- Create Notification_Templates table
CREATE TABLE notification_templates (
    template_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    subject VARCHAR(100) NOT NULL,
    body TEXT NOT NULL,
    notification_type ENUM('Email', 'SMS', 'Push') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Notifications table
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    template_id INT NOT NULL,
    sent_datetime DATETIME,
    status ENUM('Pending', 'Sent', 'Failed') DEFAULT 'Pending',
    error_message TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES notification_templates(template_id) ON DELETE RESTRICT
);

-- Create indexes for frequently queried columns
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_borrowings_member ON borrowings(member_id);
CREATE INDEX idx_borrowings_status ON borrowings(status);

-- Insert Members
INSERT INTO members (first_name, last_name, email, phone_number, address, date_of_birth, membership_start_date, membership_end_date, status) VALUES
("Juma", "Otieno", "jotieno@gmail.com", "+254 722 111 222", "123 Moi Avenue, Nairobi", "1990-05-12", "2020-01-15", "2023-01-15", "Active"),
("Faith", "Muthoni", "fmuthoni@yahoo.com", "+254 733 222 333", "456 Kenyatta Street, Nakuru", "1985-11-23", "2019-06-22", "2022-06-22", "Active"),
("Amina", "Hassan", "ahassan@gmail.com", "+254 711 333 444", "789 Oginga Odinga Road, Kisumu", "1992-03-08", "2021-02-10", "2024-02-10", "Active"),
("Kiprop", "Tanui", "ktanui@outlook.com", "+254 722 444 555", "101 Kimathi Street, Eldoret", "1978-07-19", "2018-09-05", "2021-09-05", "Inactive"),
("Atieno", "Adhiambo", "aadhiambo@gmail.com", "+254 733 555 666", "202 Biashara Street, Mombasa", "1995-01-30", "2020-11-17", "2023-11-17", "Active"),
("Waweru", "Njoroge", "wnjoroge@yahoo.com", "+254 711 666 777", "303 Tom Mboya Street, Nairobi", "1982-09-14", "2019-04-30", "2022-04-30", "Active"),
("Njoki", "Maina", "nmaina@gmail.com", "+254 722 777 888", "404 Ronald Ngala Street, Thika", "1998-12-05", "2021-08-22", "2024-08-22", "Active"),
("Mohammed", "Ali", "mali@outlook.com", "+254 733 888 999", "505 Nkrumah Road, Mombasa", "1987-06-17", "2018-03-14", "2021-03-14", "Suspended"),
("Wanjiru", "Kimani", "wkimani@gmail.com", "+254 711 999 000", "606 Uhuru Highway, Nairobi", "1993-10-25", "2020-05-28", "2023-05-28", "Active"),
("Ochieng", "Odongo", "oodongo@yahoo.com", "+254 722 000 111", "707 Haile Selassie Avenue, Kisumu", "1980-02-11", "2019-12-09", "2022-12-09", "Active"),
("Nyambura", "Gathoni", "ngathoni@gmail.com", "+254 733 112 233", "808 Tubman Road, Nairobi", "1997-04-03", "2021-01-19", "2024-01-19", "Active"),
("Kibet", "Korir", "kkorir@outlook.com", "+254 711 223 334", "909 Moi Avenue, Nakuru", "1984-08-22", "2018-07-31", "2021-07-31", "Active"),
("Auma", "Onyango", "aonyango@gmail.com", "+254 722 334 445", "1010 Kenyatta Avenue, Kisumu", "1991-12-14", "2020-10-05", "2023-10-05", "Active"),
("Gitonga", "Muriithi", "gmuriithi@yahoo.com", "+254 733 445 556", "1111 Kimathi Street, Nyeri", "1979-03-27", "2019-02-12", "2022-02-12", "Active");

-- Insert Librarians
INSERT INTO librarians (first_name, last_name, email, phone_number, position, hire_date) VALUES
("Wambui", "Kamau", "wkamau@library.co.ke", "+254 722 123 456", "Head Librarian", "2010-06-15"),
("Mwangi", "Kariuki", "mkariuki@library.co.ke", "+254 733 234 567", "Reference Librarian", "2015-03-22"),
("Akinyi", "Odhiambo", "aodhiambo@library.co.ke", "+254 711 345 678", "Circulation Manager", "2012-11-05"),
("Mutua", "Kilonzo", "mkilonzo@library.co.ke", "+254 722 456 789", "Children's Librarian", "2018-07-30"),
("Njeri", "Wanjiku", "nwanjiku@library.co.ke", "+254 733 567 890", "Technical Services Librarian", "2016-01-12");

-- Insert Categories
INSERT INTO categories (name, description) VALUES
("Fiction", "Novels, short stories, and other imaginative literature"),
("Non-Fiction", "Factual content based on real events and information"),
("Science Fiction", "Speculative fiction dealing with imaginative concepts"),
("Mystery", "Fiction dealing with the solution of a crime or puzzle"),
("Biography", "Accounts of people's lives written by another person"),
("History", "Books about past events and human societies"),
("Science", "Books about scientific discoveries and knowledge"),
("Self-Help", "Books aimed at guiding readers to solve personal problems");

-- Insert Publishers
INSERT INTO publishers (name, contact_person, email, phone_number, address) VALUES
("Penguin Random House", "Sarah Johnson", "sjohnson@penguinrandom.com", "+254 711 123 456", "International Publisher"),
("HarperCollins", "Michael Chen", "mchen@harpercollins.com", "+254 722 234 567", "International Publisher"),
("Simon & Schuster", "David Miller", "dmiller@simonschuster.com", "+254 733 345 678", "International Publisher"),
("Macmillan Publishers", "Emily Wilson", "ewilson@macmillan.com", "+254 744 456 789", "International Publisher"),
("Oxford University Press", "James Thompson", "jthompson@oup.com", "+254 755 567 890", "International Publisher"),
("Longhorn Publishers", "Wanjiku Mwangi", "wmwangi@longhorn.co.ke", "+254 722 987 654", "Funzi Road, Industrial Area, Nairobi");

-- Insert Authors
INSERT INTO authors (first_name, last_name, biography, birth_date, nationality) VALUES
("J.K.", "Rowling", "British author best known for the Harry Potter series", "1965-07-31", "British"),
("Stephen", "King", "American author of horror, supernatural fiction, and fantasy", "1947-09-21", "American"),
("Michelle", "Obama", "American attorney, university administrator, and writer who served as First Lady", "1964-01-17", "American"),
("Yuval Noah", "Harari", "Israeli public intellectual, historian and professor", "1976-02-24", "Israeli"),
("George R.R.", "Martin", "American novelist and short story writer, screenwriter, and television producer", "1948-09-20", "American"),
("Chimamanda Ngozi", "Adichie", "Nigerian writer whose works include novels, short stories and nonfiction", "1977-09-15", "Nigerian"),
("Ngugi Wa", "Thiong'o", "Kenyan writer and academic who writes in Gikuyu and English", "1938-01-05", "Kenyan"),
("Binyavanga", "Wainaina", "Kenyan author, journalist and winner of the Caine Prize", "1971-01-18", "Kenyan");

-- Insert Books
INSERT INTO books (title, isbn, publisher_id, publication_date, edition, pages, language, summary, shelf_location, category_id) VALUES
("Harry Potter and the Philosopher's Stone", "9780747532743", 1, "1997-06-26", "First Edition", 223, "English", "The first novel in the Harry Potter series", "A1-01", 1),
("The Shining", "9780385121675", 2, "1977-01-28", "First Edition", 447, "English", "A horror novel about a family staying at an isolated hotel", "B2-05", 1),
("Becoming", "9781524763138", 3, "2018-11-13", "First Edition", 448, "English", "Memoir of former First Lady of the United States", "C3-02", 5),
("Sapiens: A Brief History of Humankind", "9780062316097", 4, "2014-02-10", "First Edition", 443, "English", "A book about the history and evolution of Homo sapiens", "D4-03", 2),
("A Game of Thrones", "9780553103540", 5, "1996-08-01", "First Edition", 694, "English", "The first novel in A Song of Ice and Fire series", "A1-02", 1),
("Half of a Yellow Sun", "9780007200283", 1, "2006-08-11", "First Edition", 448, "English", "Story set during the Biafran War", "E5-01", 1),
("Wizard of the Crow", "9780099494096", 2, "2006-08-08", "First Edition", 768, "English", "Political satire about a fictional African country", "B2-03", 1),
("Born a Crime", "9780399588174", 3, "2016-11-15", "First Edition", 304, "English", "Stories from a South African childhood", "A1-03", 5),
("Things Fall Apart", "9780385474542", 6, "1958-01-01", "First Edition", 209, "English", "Story about pre-colonial life in Nigeria and the arrival of Europeans", "F6-02", 1),
("Long Walk to Freedom", "9780316548182", 1, "1994-12-01", "First Edition", 630, "English", "Autobiography of Nelson Mandela", "A1-04", 5);

-- Insert Book_Authors
INSERT INTO book_authors (book_id, author_id, role) VALUES
(1, 1, "Primary"),
(2, 2, "Primary"),
(3, 3, "Primary"),
(4, 4, "Primary"),
(5, 5, "Primary"),
(6, 6, "Primary"),
(7, 7, "Primary"),
(8, 8, "Primary"),
(9, 7, "Primary"),
(10, 8, "Co-author");

-- Insert Book_Copies
INSERT INTO book_copies (book_id, barcode, book_condition, acquisition_date, price, status) VALUES
(1, "KNL-B1-001", "Good", "2018-01-10", 1999.00, "Available"),
(1, "KNL-B1-002", "Good", "2018-01-10", 1999.00, "Borrowed"),
(2, "KNL-B2-001", "New", "2018-06-14", 1500.00, "Available"),
(3, "KNL-B3-001", "Good", "2019-04-22", 2500.00, "Reserved"),
(4, "KNL-B4-001", "Good", "2019-08-15", 1750.00, "Available"),
(5, "KNL-B5-001", "Fair", "2020-02-25", 3000.00, "Borrowed"),
(6, "KNL-B6-001", "Good", "2018-10-09", 1400.00, "Available"),
(7, "KNL-B7-001", "Fair", "2021-01-03", 1300.00, "Available"),
(8, "KNL-B8-001", "New", "2021-06-02", 2200.00, "Available"),
(9, "KNL-B9-001", "Good", "2022-02-15", 1999.00, "Borrowed"),
(10, "KNL-B10-001", "Poor", "2022-11-20", 950.00, "Lost");

-- Insert Borrowings
INSERT INTO borrowings (copy_id, member_id, librarian_id_checkout, borrow_date, due_date, status)
VALUES
(2, 1, 1, "2023-06-01 10:00:00", "2023-06-15 23:59:59", "Returned"),
(5, 3, 2, "2023-06-05 11:00:00", "2023-06-19 23:59:59", "Active"),
(9, 4, 3, "2023-05-20 09:00:00", "2023-06-03 23:59:59", "Overdue"),
(3, 2, 1, "2023-05-25 15:00:00", "2023-06-08 23:59:59", "Returned"),
(10, 8, 4, "2023-06-09 16:00:00", "2023-06-23 23:59:59", "Lost");

-- Insert Reservations
INSERT INTO reservations (book_id, member_id, reservation_date, expiry_date, status)
VALUES
(1, 5, "2023-04-01 10:30:00", "2023-04-08 23:59:59", "Fulfilled"),
(4, 2, "2023-05-10 11:15:00", "2023-05-17 23:59:59", "Fulfilled"),
(7, 3, "2023-05-18 09:40:00", "2023-05-25 23:59:59", "Pending"),
(8, 1, "2023-06-03 08:30:00", "2023-06-10 23:59:59", "Cancelled"),
(9, 10, "2023-06-11 13:25:00", "2023-06-18 23:59:59", "Pending");

-- Insert Fines
INSERT INTO fines (borrowing_id, member_id, amount, reason, issue_date, status, librarian_id)
VALUES
(3, 4, 650.00, "Overdue book", "2023-06-05", "Pending", 2),
(5, 8, 1000.00, "Lost book", "2023-06-25", "Pending", 4),
(1, 1, 100.00, "Returned late", "2023-06-17", "Paid", 1),
(4, 2, 250.00, "Returned late", "2023-06-10", "Paid", 3),
(2, 3, 0.00, "Courtesy notice", "2023-06-19", "Waived", 2);

-- Insert Events
INSERT INTO events (title, description, start_datetime, end_datetime, location, max_attendees, event_type, librarian_id)
VALUES
("Madaraka Day Reading Festival", "Celebrate Madaraka Day with reading challenges and prizes!", "2023-06-01 14:00:00", "2023-06-01 17:00:00", "Community Hall", 50, "Book Reading", 1),
("Swahili Night", "Celebrate Swahili literature and storytelling.", "2023-06-13 18:00:00", "2023-06-13 21:00:00", "Main Hall", 30, "Workshop", 2),
("Author Visit: Ngugi Wa Thiong'o", "Meet and greet with renowned Kenyan author.", "2023-07-10 16:00:00", "2023-07-10 18:00:00", "Auditorium", 100, "Author Visit", 4),
("Children's Story Time", "Stories and crafts for kids in English and Swahili.", "2023-06-19 10:00:00", "2023-06-19 11:30:00", "Children's Area", 20, "Children Program", 4),
("Kenyan History Book Club", "Discuss this month's selection on Kenyan history.", "2023-06-25 19:00:00", "2023-06-25 21:00:00", "Meeting Room B", 15, "Other", 3);

-- Insert Event_Registrations
INSERT INTO event_registrations (event_id, member_id, registration_date, attendance_status)
VALUES
(1, 1, "2023-05-20", "Attended"),
(1, 2, "2023-05-21", "Registered"),
(2, 3, "2023-06-01", "Attended"),
(3, 5, "2023-06-13", "Registered"),
(4, 4, "2023-06-10", "Attended");

-- Insert Book_Reviews
INSERT INTO book_reviews (book_id, member_id, rating, review_text, review_date, is_approved)
VALUES
(1, 1, 5, "Absolutely magical, loved every page!", "2023-06-16", 1),
(2, 3, 4, "Chilling and tense.", "2023-06-18", 1),
(4, 4, 5, "Eye-opening and thought-provoking.", "2023-05-29", 1),
(7, 5, 3, "Powerful but challenging.", "2023-06-10", 1),
(8, 2, 4, "Highly recommended for everyone.", "2023-06-05", 0);

-- Insert Inventory_Log
INSERT INTO inventory_log (copy_id, action, action_date, previous_status, new_status, previous_condition, new_condition, notes, librarian_id)
VALUES
(2, "Status Change", "2023-06-01", "Available", "Borrowed", NULL, NULL, "Checked out to member", 1),
(5, "Status Change", "2023-06-05", "Available", "Borrowed", NULL, NULL, "Checked out to member", 2),
(9, "Status Change", "2023-05-20", "Available", "Borrowed", NULL, NULL, "Checked out to member", 3),
(3, "Status Change", "2023-05-25", "Available", "Borrowed", NULL, NULL, "Checked out to member", 1),
(10, "Status Change", "2023-06-09", "Available", "Borrowed", NULL, NULL, "Checked out to member", 4),
(10, "Status Change", "2023-06-25", "Borrowed", "Lost", NULL, NULL, "Reported lost by member", 4),
(3, "Condition Change", "2023-06-08", NULL, NULL, "New", "Good", "Some wear on cover noted upon return", 2);

-- Insert Notification_Templates
INSERT INTO notification_templates (name, subject, body, notification_type)
VALUES
("Overdue Notice", "Your library book is overdue", "Dear {memberName}, our records show that you have an overdue item: {bookTitle}. Please return it as soon as possible to avoid further fines.", "Email"),
("Reservation Ready", "Your reserved book is available", "Good news! The book you reserved, {bookTitle}, is now available for pickup. Please visit the library within the next 3 days.", "Email"),
("Event Reminder", "Reminder: Upcoming library event", "This is a reminder that you have registered for {eventName} on {eventDate}. We look forward to seeing you!", "Email"),
("Fine Notice", "Library fine notification", "You have an outstanding fine of KES {amount} for {reason}. Please settle this during your next library visit.", "Email"),
("Account Expiry", "Your library membership is expiring", "Your membership expires on {expiryDate}. Please visit the library to renew your membership and continue enjoying our services.", "Email");

-- Insert Notifications
INSERT INTO notifications (member_id, template_id, sent_datetime, status)
VALUES
(4, 1, "2023-06-05 08:00:00", "Sent"),
(5, 2, "2023-04-01 09:30:00", "Sent"),
(3, 3, "2023-06-12 10:00:00", "Sent"),
(8, 4, "2023-06-25 11:30:00", "Sent"),
(1, 3, "2023-05-31 08:00:00", "Failed"),
(2, 3, "2023-05-31 08:00:00", "Sent");

-- 1. Members
SELECT * FROM members;

-- 2. Librarians
SELECT * FROM librarians;

-- 3. Categories
SELECT * FROM categories;

-- 4. Publishers
SELECT * FROM publishers;

-- 5. Authors
SELECT * FROM authors;

-- 6. Books
SELECT * FROM books;

-- 7. Book_Authors
SELECT * FROM book_authors;

-- 8. Book_Copies
SELECT * FROM book_copies;

-- 9. Borrowings
SELECT * FROM borrowings;

-- 10. Reservations
SELECT * FROM reservations;

-- 11. Fines
SELECT * FROM fines;

-- 12. Events
SELECT * FROM events;

-- 13. Event_Registrations
SELECT * FROM event_registrations;

-- 14. Book_Reviews
SELECT * FROM book_reviews;

-- 15. Inventory_Log
SELECT * FROM inventory_log;

-- 16. Notification_Templates
SELECT * FROM notification_templates;

-- 17. Notifications
SELECT * FROM notifications;




