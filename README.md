# Gemini Web To API - Claude Code & VS Code Edition

Dự án này là bản mở rộng từ mã nguồn mở [gemini-web-to-api](https://github.com/ntthanh2603/gemini-web-to-api) của tác giả **Nguyễn Tuấn Thành ([@ntthanh2603](https://github.com/ntthanh2603))**. 

Bản fork/mở rộng này bổ sung bộ công cụ cài đặt tự động cho **Claude Code** trên **VS Code**, hỗ trợ đầy đủ model lý luận sâu **`gemini-4-argon`** cùng các model Gemini khác (`gemini-3.8-flash`, `gemini-3.1-pro`, `gemini-3.5-flash-lite`) hoàn toàn miễn phí thông qua Cookies tài khoản Gemini Web cá nhân.

---

## Lời cảm ơn & Nguồn gốc (Credits)

Dự án gốc: **[https://github.com/ntthanh2603/gemini-web-to-api](https://github.com/ntthanh2603/gemini-web-to-api)**  
Tác giả gốc: **[@ntthanh2603](https://github.com/ntthanh2603)**

Gửi lời cảm ơn chân thành tới anh **Nguyễn Tiến Thành** vì đã nghiên cứu, hiện thực hóa và chia sẻ giải pháp cầu nối Gemini Web to API cho cộng đồng lập trình viên Việt Nam và quốc tế.

---

## Những điểm bổ sung trong bản này

1. **Hỗ trợ trọn vẹn Claude Code trên VS Code:**
   * Tự động ánh xạ (mapping / reflecting) các tên gọi model của Claude (`claude-3-7-sonnet`, `claude-3-opus`, `claude-3-5-haiku`) sang các model tương ứng của Gemini trên backend mà không bị lỗi `unsupported model`.
   * Cung cấp endpoint `/claude/v1/messages` tương thích hoàn toàn với Claude Code CLI và VS Code extension.

2. **Hỗ trợ model suy luận sâu `gemini-4-argon`:**
   * Tích hợp cơ chế reasoning và hỗ trợ các mức Effort (`Low`, `Medium`, `High`) của Claude Code.

3. **Script cài đặt 1-click cho Windows (`Setup_Claude_Gemini.bat`):**
   * Nhập cookie an toàn, không lo bị cmd cắt ngắn chuỗi cookie dài hàng nghìn ký tự.
   * Menu chọn model và mức độ suy nghĩ trực quan ngay trong terminal.
   * Tự động tạo key Anthropic mẫu (`sk-ant-api03-...`).
   * Tự động cập nhật file `settings.json` của VS Code và `~/.claude/settings.json` mà không làm mất cấu hình có sẵn của bạn.

---

## Chuẩn bị

1. **Golang:** Cần cài đặt Go (phiên bản 1.21 trở lên) để chạy server. Tải bộ cài Windows tại [go.dev/dl](https://go.dev/dl/).
2. **VS Code & Extension:**
   * Tải và cài đặt [Visual Studio Code](https://code.visualstudio.com/).
   * Vào mục Extensions (`Ctrl + Shift + X`), tìm và cài đặt extension chính thức **`Claude Code`** (của Anthropic).

---

## Hướng dẫn cài đặt A - Z

### Bước 1: Lấy Cookie từ Gemini Web

1. Mở trình duyệt web, truy cập [gemini.google.com](https://gemini.google.com) và đăng nhập tài khoản Google.
2. Nhấn phím `F12` để mở công cụ nhà phát triển, chuyển sang tab **Network**.
3. Nhấn `F5` để tải lại trang.
4. Ở ô lọc tìm kiếm của tab Network, gõ `batchexecute`.
5. Bấm vào một request `batchexecute`, nhìn sang khung bên phải mục **Headers**, cuộn xuống phần **Request Headers**.
6. Copy toàn bộ chuỗi ký tự trong mục **`Cookie`** (chuỗi bắt đầu bằng `SID=g.a000...`).

> **Mẹo:** Nếu thanh địa chỉ trình duyệt của bạn có dạng `gemini.google.com/u/1/app` (tài khoản số 1), hãy ghi nhớ số `1` này để nhập vào bước tiếp theo.

---

### Bước 2: Chạy cài đặt tự động

1. Tải thư mục này về máy.
2. Nhấp đúp chuột vào file **`Setup_Claude_Gemini.bat`**.
3. Cửa sổ terminal hiện lên:
   * **Nhập Cookie:** Nhấp chuột phải (hoặc nhấn `Ctrl + V`) để dán chuỗi cookie vừa copy ở Bước 1 ➔ Nhấn `Enter`.
   * **Nhập slot tài khoản:** Nhập số slot tài khoản của bạn (mặc định là `1` nếu URL có `/u/1/`, hoặc bấm `Enter` để chọn 1).
   * **Chọn model cho Claude Code:**
     * `[1] gemini-4-argon` *(Mô hình suy luận sâu mới nhất, xử lý tác vụ phức tạp và viết code chính xác)*
     * `[2] gemini-3.8-flash` *(Phản hồi nhanh trong 3-5 giây)*
     * `[3] gemini-3.1-pro` *(Thông minh cao, phản hồi trong khoảng 7 giây)*
     * `[4] gemini-3.5-flash-lite` *(Siêu nhẹ)*
   * **Chọn mức độ suy nghĩ (Effort Level) nếu chọn Argon:**
     * `[1] Low` *(Phản hồi nhanh khoảng 10-15s, khuyên dùng cho công việc hàng ngày)*
     * `[2] Medium` *(Khoảng 20-25s)*
     * `[3] High` *(Suy nghĩ sâu kỹ lưỡng)*
4. Script sẽ tự động:
   * Tạo file `.env` cho server.
   * Thiết lập file cài đặt người dùng của VS Code (`%APPDATA%\Code\User\settings.json`).
   * Thiết lập file cài đặt của Claude Code CLI (`~/.claude/settings.json`).
5. Khi script hỏi `Bạn có muốn khởi động Server ngay bây giờ không?`, nhập `Y` (hoặc nhấn `Enter`) để server bắt đầu chạy.

---

### Bước 3: Sử dụng trên VS Code

1. Giữ cửa sổ server đang chạy (trên cổng `http://127.0.0.1:4981`).
2. Mở **VS Code**. Nếu VS Code đang mở sẵn, nhấn tổ hợp `Ctrl + Shift + P` ➔ gõ `Developer: Reload Window` để nhận cài đặt mới.
3. Bấm vào biểu tượng **Claude Code** trên thanh bên (Activity Bar) hoặc mở panel Claude Code.
4. Bạn sẽ thấy model đã được chọn sẵn (ví dụ: `gemini-4-argon Low`).
5. Nhập câu hỏi hoặc yêu cầu lập trình và bắt đầu làm việc.

---

## Những lưu ý khi sử dụng

### 1. Thời gian suy nghĩ của `gemini-4-argon`
* **Gemini 4 Argon** là mô hình reasoning sâu. Khi nhận câu hỏi, mô hình sẽ dành khoảng **10 đến 25 giây** để tạo chuỗi suy nghĩ nội bộ và kiểm tra code sandbox trước khi trả lời.
* Trong thời gian này, Claude Code sẽ hiển thị trạng thái `+ Herding...`. Bạn chỉ cần đợi khoảng 15-20 giây, **không nên bấm nút dừng (stop)** giữa chừng.
* Nếu cần tốc độ trả lời ngay lập tức (3-5 giây), bạn có thể chạy lại `Setup_Claude_Gemini.bat` và chọn model **`gemini-3.8-flash`**.

### 2. Khi Cookie bị hết hạn (Lỗi Status 401)
Thỉnh thoảng khi bạn dùng Gemini Web trên trình duyệt, Google sẽ tự động xoay mã `__Secure-1PSIDTS`, làm cookie cũ trong `.env` hết hạn.
* **Dấu hiệu:** Cửa sổ server báo `authentication failed: GEMINI_COOKIES is invalid or expired` hoặc `status: 401`.
* **Cách khắc phục:** Bạn chỉ cần vào lại [gemini.google.com](https://gemini.google.com), lấy lại chuỗi Cookie mới theo Bước 1, rồi chạy lại `Setup_Claude_Gemini.bat` (hoặc dán đè vào file `.env`).

### 3. Khởi động server cho những lần sau
Những lần dùng tiếp theo, bạn không cần chạy lại file setup nữa. Chỉ cần nhấp đúp vào file **`Start_Server.bat`** là server sẽ chạy ngay.

---

## Kết nối với các ứng dụng Chat UI khác

Ngoài Claude Code, server này tương thích hoàn toàn với chuẩn OpenAI API. Bạn có thể kết nối vào các app chat mã nguồn mở như **Chatbox**, **NextChat**, **Cherry Studio**, **Open WebUI**:

* **Loại API (Provider):** `OpenAI`
* **API Host / Base URL:** `http://localhost:4981/openai/v1`
* **API Key:** Bất kỳ (ví dụ: `not-needed`)
* **Danh sách Model:** `gemini-4-argon`, `gemini-3.8-flash`, `gemini-3.1-pro`, `gemini-3.5-flash-lite`

Kiểm tra danh sách model trực tiếp trên trình duyệt: [http://localhost:4981/openai/v1/models](http://localhost:4981/openai/v1/models)  
Trang tài liệu API tương tác: [http://localhost:4981/docs](http://localhost:4981/docs)

---

## Tuyên bố miễn trừ trách nhiệm (Disclaimer)

Dự án này được phát triển và sử dụng cho mục đích **nghiên cứu, học tập và trải nghiệm cá nhân**. Dự án không liên kết với Google hay Anthropic. Việc sử dụng cookie tài khoản cần tuân thủ các điều khoản dịch vụ của nhà cung cấp.
