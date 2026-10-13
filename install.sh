#!/bin/sh
#
# safe-rm installer (integrated)
# Install safe-rm
#
# Usage:
#
#  curl -fsSL https://raw.githubusercontent.com/hestiacn/safe-rm/master/install.sh | sudo sh
#  curl -fsSL https://raw.githubusercontent.com/hestiacn/safe-rm/master/install.sh | sudo sh -s -- --uninstall
#

set -e

# Path configuration 
PREFIX="${PREFIX:-/usr/local}"

# SYSCONFDIR by platform
if [ -z "$SYSCONFDIR" ]; then
    case "$(uname -s)" in
        FreeBSD|Darwin)
            SYSCONFDIR="/usr/local/etc"
            ;;
        *)
            SYSCONFDIR="/etc"
            ;;
    esac
fi

MANDIR="${MANDIR:-$PREFIX/share/man/man1}"
DOCDIR="${DOCDIR:-$PREFIX/share/doc/safe-rm}"

BINDIR="$PREFIX/bin"
PROFILEDIR="$SYSCONFDIR/profile.d"
SYMLINKDIR="$PREFIX/share/safe-rm/bin"

# Online install configuration 
VERSION="${VERSION:-1.1.0}"
REPO="hestiacn/safe-rm"
BASE_URL="https://github.com/${REPO}/releases/download/v${VERSION}"

# Project homepage 
HOMEPAGE="https://launchpad.net/safe-rm"

# Colors 
if [ -t 1 ]; then
    ESC=$(printf '\033')
    RED="${ESC}[0;31m"
    GREEN="${ESC}[0;32m"
    YELLOW="${ESC}[0;33m"
    NC="${ESC}[0m"
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Messages (i18n) 
case "${LANG%%.*}" in
    zh_CN|zh_SG)
        MSG_INSTALL="正在安装 safe-rm 到"
        MSG_DONE="安装完成。"
        MSG_UNINSTALL="正在卸载 safe-rm..."
        MSG_UNINSTALLED="卸载完成。"
        MSG_RELOGIN="请重新登录，或运行："
        MSG_TEST="测试："
        MSG_NOT_ROOT="错误：需要 root 权限。请用 sudo 运行。"
        MSG_NO_FILE="错误：当前目录缺少"
        MSG_ALREADY="safe-rm 已安装"
        MSG_UNINSTALL_HINT="卸载请运行："
        MSG_PATH_SETUP="PATH 设置："
        MSG_PATH_STANDARD="标准："
        MSG_PATH_OVERRIDE="如果 shell 覆盖 PATH，加到 shell 配置："
        MSG_UPDATE_TITLE="请使用以下命令更新保护列表："
        MSG_UPDATE_CONF="更新 $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="注意：默认保护路径因不同发行版目录差异。\n安装自带的 safe-rm.conf 是通用默认值，\n可能与你的系统不完全匹配。\n建议执行 update-safe-rm，根据当前系统生成最合适的保护列表。"
        MSG_HOMEPAGE="项目主页："
        MSG_INSTALLED_FILES="已安装文件："
        MSG_DOWNLOADING="正在下载..."
        MSG_EXTRACTING="正在解压..."
        MSG_UNSUPPORTED="不支持："
        MSG_NEED_TOOLS="错误：缺少必要工具。"
        MSG_MANUAL_INSTALL="请先手动安装以下工具后重试："
        MSG_DOWNLOAD_FAILED="下载失败"
        MSG_EXTRACT_FAILED="解压失败"
        ;;
    zh_TW|zh_HK)
        MSG_INSTALL="正在安裝 safe-rm 到"
        MSG_DONE="安裝完成。"
        MSG_UNINSTALL="正在卸載 safe-rm..."
        MSG_UNINSTALLED="卸載完成。"
        MSG_RELOGIN="請重新登入，或執行："
        MSG_TEST="測試："
        MSG_NOT_ROOT="錯誤：需要 root 權限。請用 sudo 執行。"
        MSG_NO_FILE="錯誤：當前目錄缺少"
        MSG_ALREADY="safe-rm 已安裝"
        MSG_UNINSTALL_HINT="卸載請執行："
        MSG_PATH_SETUP="PATH 設定："
        MSG_PATH_STANDARD="標準："
        MSG_PATH_OVERRIDE="如果 shell 覆蓋 PATH，加到 shell 設定："
        MSG_UPDATE_TITLE="更新保護列表："
        MSG_UPDATE_CONF="更新 $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="注意：預設保護路徑因不同發行版目錄差異。\n安裝自帶的 safe-rm.conf 是通用預設值，\n可能與你的系統不完全匹配。\n建議執行 update-safe-rm，根據當前系統生成最合適的保護列表。"
        MSG_HOMEPAGE="專案首頁："
        MSG_INSTALLED_FILES="已安裝檔案："
        MSG_DOWNLOADING="正在下載..."
        MSG_EXTRACTING="正在解壓..."
        MSG_UNSUPPORTED="不支援："
        MSG_NEED_TOOLS="錯誤：缺少必要工具。"
        MSG_MANUAL_INSTALL="請先手動安裝以下工具後重試："
        MSG_DOWNLOAD_FAILED="下載失敗"
        MSG_EXTRACT_FAILED="解壓失敗"
        ;;
    ja_JP)
        MSG_INSTALL="safe-rm をインストール中:"
        MSG_DONE="インストール完了。"
        MSG_UNINSTALL="safe-rm をアンインストール中..."
        MSG_UNINSTALLED="アンインストール完了。"
        MSG_RELOGIN="再ログインするか、実行してください："
        MSG_TEST="テスト："
        MSG_NOT_ROOT="エラー：root 権限が必要です。sudo で実行してください。"
        MSG_NO_FILE="エラー：カレントディレクトリにありません"
        MSG_ALREADY="safe-rm は既にインストールされています"
        MSG_UNINSTALL_HINT="アンインストール："
        MSG_PATH_SETUP="PATH 設定:"
        MSG_PATH_STANDARD="標準:"
        MSG_PATH_OVERRIDE="shell が PATH を上書きする場合、shell 設定に追加:"
        MSG_UPDATE_TITLE="保護リストを更新:"
        MSG_UPDATE_CONF="$SYSCONFDIR/safe-rm.conf を更新"
        MSG_UPDATE_DESC="注意：デフォルトの保護パスはディストリビューションごとに異なります。\n同梱の safe-rm.conf は汎用的な初期値であり、\nお使いのシステムと完全には一致しない場合があります。\nupdate-safe-rm を実行し、現在のシステムに最適な保護リストを生成することを推奨します。"
        MSG_HOMEPAGE="プロジェクトホーム:"
        MSG_INSTALLED_FILES="インストール済みファイル:"
        MSG_DOWNLOADING="ダウンロード中..."
        MSG_EXTRACTING="展開中..."
        MSG_UNSUPPORTED="未対応："
        MSG_NEED_TOOLS="エラー：必要なツールがありません。"
        MSG_MANUAL_INSTALL="先に以下のツールを手動でインストールしてから再実行してください:"
        MSG_DOWNLOAD_FAILED="ダウンロード失敗"
        MSG_EXTRACT_FAILED="展開失敗"
        ;;
    ko_KR)
        MSG_INSTALL="safe-rm 설치 중:"
        MSG_DONE="설치 완료."
        MSG_UNINSTALL="safe-rm 제거 중..."
        MSG_UNINSTALLED="제거 완료."
        MSG_RELOGIN="다시 로그인하거나 다음을 실행하세요:"
        MSG_TEST="테스트:"
        MSG_NOT_ROOT="오류: root 권한이 필요합니다. sudo로 실행하세요."
        MSG_NO_FILE="오류: 현재 디렉터리에 없음"
        MSG_ALREADY="safe-rm이 이미 설치되어 있습니다"
        MSG_UNINSTALL_HINT="제거하려면 실행:"
        MSG_PATH_SETUP="PATH 설정:"
        MSG_PATH_STANDARD="표준:"
        MSG_PATH_OVERRIDE="셸이 PATH를 덮어쓰는 경우 셸 설정에 추가:"
        MSG_UPDATE_TITLE="보호 목록 업데이트:"
        MSG_UPDATE_CONF="$SYSCONFDIR/safe-rm.conf 업데이트"
        MSG_UPDATE_DESC="참고: 기본 보호 경로는 배포판마다 다릅니다.\n번들된 safe-rm.conf는 일반 기본값이며\n시스템과 완전히 일치하지 않을 수 있습니다.\nupdate-safe-rm을 실행하여 현재 시스템에 맞는\n보호 목록을 생성하는 것을 권장합니다."
        MSG_HOMEPAGE="프로젝트 홈페이지:"
        MSG_INSTALLED_FILES="설치된 파일:"
        MSG_DOWNLOADING="다운로드 중..."
        MSG_EXTRACTING="압축 해제 중..."
        MSG_UNSUPPORTED="지원되지 않음:"
        MSG_NEED_TOOLS="오류: 필요한 도구가 없습니다."
        MSG_MANUAL_INSTALL="다음 도구를 수동으로 설치한 후 다시 시도하세요:"
        MSG_DOWNLOAD_FAILED="다운로드 실패"
        MSG_EXTRACT_FAILED="압축 해제 실패"
        ;;
    vi_VN)
        MSG_INSTALL="Đang cài đặt safe-rm vào"
        MSG_DONE="Cài đặt hoàn tất."
        MSG_UNINSTALL="Đang gỡ cài đặt safe-rm..."
        MSG_UNINSTALLED="Gỡ cài đặt hoàn tất."
        MSG_RELOGIN="Vui lòng đăng nhập lại hoặc chạy:"
        MSG_TEST="Kiểm tra:"
        MSG_NOT_ROOT="Lỗi: cần quyền root. Chạy bằng sudo."
        MSG_NO_FILE="Lỗi: thiếu trong thư mục hiện tại"
        MSG_ALREADY="safe-rm đã được cài đặt"
        MSG_UNINSTALL_HINT="Để gỡ cài đặt, chạy:"
        MSG_PATH_SETUP="Thiết lập PATH:"
        MSG_PATH_STANDARD="Tiêu chuẩn:"
        MSG_PATH_OVERRIDE="Nếu shell ghi đè PATH, thêm vào cấu hình shell:"
        MSG_UPDATE_TITLE="Cập nhật danh sách bảo vệ:"
        MSG_UPDATE_CONF="cập nhật $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Lưu ý: các đường dẫn bảo vệ mặc định khác nhau giữa các bản phân phối.\nsafe-rm.conf đi kèm là giá trị mặc định chung và\ncó thể không khớp hoàn toàn với hệ thống của bạn.\nNên chạy update-safe-rm để tạo danh sách\nbảo vệ phù hợp nhất cho hệ thống hiện tại."
        MSG_HOMEPAGE="Trang chủ dự án:"
        MSG_INSTALLED_FILES="Tệp đã cài đặt:"
        MSG_DOWNLOADING="Đang tải xuống..."
        MSG_EXTRACTING="Đang giải nén..."
        MSG_UNSUPPORTED="Không hỗ trợ:"
        MSG_NEED_TOOLS="Lỗi: thiếu công cụ cần thiết."
        MSG_MANUAL_INSTALL="Vui lòng cài đặt thủ công các công cụ sau rồi thử lại:"
        MSG_DOWNLOAD_FAILED="Tải xuống thất bại"
        MSG_EXTRACT_FAILED="Giải nén thất bại"
        ;;
    th_TH)
        MSG_INSTALL="กำลังติดตั้ง safe-rm ไปที่"
        MSG_DONE="ติดตั้งเสร็จสิ้น"
        MSG_UNINSTALL="กำลังถอนการติดตั้ง safe-rm..."
        MSG_UNINSTALLED="ถอนการติดตั้งเสร็จสิ้น"
        MSG_RELOGIN="โปรดเข้าสู่ระบบใหม่ หรือรัน:"
        MSG_TEST="ทดสอบ:"
        MSG_NOT_ROOT="ข้อผิดพลาด: ต้องใช้สิทธิ์ root รันด้วย sudo"
        MSG_NO_FILE="ข้อผิดพลาด: ไม่พบในไดเรกทอรีปัจจุบัน"
        MSG_ALREADY="safe-rm ติดตั้งแล้ว"
        MSG_UNINSTALL_HINT="หากต้องการถอนการติดตั้ง ให้รัน:"
        MSG_PATH_SETUP="การตั้งค่า PATH:"
        MSG_PATH_STANDARD="มาตรฐาน:"
        MSG_PATH_OVERRIDE="หากเชลล์เขียนทับ PATH ให้เพิ่มในไฟล์กำหนดค่าเชลล์:"
        MSG_UPDATE_TITLE="อัปเดตรายการป้องกัน:"
        MSG_UPDATE_CONF="อัปเดต $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="หมายเหตุ: เส้นทางการป้องกันเริ่มต้นแตกต่างกันในแต่ละดิสทริบิวชัน\nsafe-rm.conf ที่มาพร้อมเป็นค่าเริ่มต้นทั่วไปและ\nอาจไม่ตรงกับระบบของคุณทั้งหมด\nแนะนำให้รัน update-safe-rm เพื่อสร้างรายการ\nป้องกันที่เหมาะสมที่สุดสำหรับระบบปัจจุบัน"
        MSG_HOMEPAGE="หน้าแรกของโครงการ:"
        MSG_INSTALLED_FILES="ไฟล์ที่ติดตั้ง:"
        MSG_DOWNLOADING="กำลังดาวน์โหลด..."
        MSG_EXTRACTING="กำลังแตกไฟล์..."
        MSG_UNSUPPORTED="ไม่รองรับ:"
        MSG_NEED_TOOLS="ข้อผิดพลาด: เครื่องมือที่จำเป็นหายไป"
        MSG_MANUAL_INSTALL="โปรดติดตั้งเครื่องมือต่อไปนี้ด้วยตนเองแล้วลองใหม่:"
        MSG_DOWNLOAD_FAILED="ดาวน์โหลดล้มเหลว"
        MSG_EXTRACT_FAILED="แตกไฟล์ล้มเหลว"
        ;;
    id_ID)
        MSG_INSTALL="Memasang safe-rm ke"
        MSG_DONE="Pemasangan selesai."
        MSG_UNINSTALL="Menghapus safe-rm..."
        MSG_UNINSTALLED="Penghapusan selesai."
        MSG_RELOGIN="Silakan login ulang, atau jalankan:"
        MSG_TEST="Uji:"
        MSG_NOT_ROOT="Kesalahan: butuh root. Jalankan dengan sudo."
        MSG_NO_FILE="Kesalahan: tidak ada di direktori saat ini"
        MSG_ALREADY="safe-rm sudah terpasang"
        MSG_UNINSTALL_HINT="Untuk menghapus, jalankan:"
        MSG_PATH_SETUP="Pengaturan PATH:"
        MSG_PATH_STANDARD="Standar:"
        MSG_PATH_OVERRIDE="Jika shell menimpa PATH, tambahkan ke konfigurasi shell:"
        MSG_UPDATE_TITLE="Perbarui daftar perlindungan:"
        MSG_UPDATE_CONF="perbarui $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Catatan: jalur perlindungan default berbeda antar distribusi.\nsafe-rm.conf bawaan adalah default umum dan\nmungkin tidak sepenuhnya cocok dengan sistem Anda.\nDisarankan menjalankan update-safe-rm untuk menghasilkan\ndaftar perlindungan yang paling sesuai untuk sistem saat ini."
        MSG_HOMEPAGE="Beranda proyek:"
        MSG_INSTALLED_FILES="File terpasang:"
        MSG_DOWNLOADING="Mengunduh..."
        MSG_EXTRACTING="Mengekstrak..."
        MSG_UNSUPPORTED="Tidak didukung:"
        MSG_NEED_TOOLS="Kesalahan: alat yang diperlukan tidak ada."
        MSG_MANUAL_INSTALL="Silakan pasang alat berikut secara manual lalu coba lagi:"
        MSG_DOWNLOAD_FAILED="Unduhan gagal"
        MSG_EXTRACT_FAILED="Ekstraksi gagal"
        ;;
    ms_MY)
        MSG_INSTALL="Memasang safe-rm ke"
        MSG_DONE="Pemasangan selesai."
        MSG_UNINSTALL="Menyahpasang safe-rm..."
        MSG_UNINSTALLED="Nyahpasang selesai."
        MSG_RELOGIN="Sila log masuk semula, atau jalankan:"
        MSG_TEST="Ujian:"
        MSG_NOT_ROOT="Ralat: perlukan root. Jalankan dengan sudo."
        MSG_NO_FILE="Ralat: tiada dalam direktori semasa"
        MSG_ALREADY="safe-rm sudah dipasang"
        MSG_UNINSTALL_HINT="Untuk nyahpasang, jalankan:"
        MSG_PATH_SETUP="Tetapan PATH:"
        MSG_PATH_STANDARD="Standard:"
        MSG_PATH_OVERRIDE="Jika shell mengatasi PATH, tambah ke konfigurasi shell:"
        MSG_UPDATE_TITLE="Kemas kini senarai perlindungan:"
        MSG_UPDATE_CONF="kemas kini $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Nota: laluan perlindungan lalai berbeza antara distribusi.\nsafe-rm.conf terbina ialah nilai lalai umum dan\nmungkin tidak sepadan sepenuhnya dengan sistem anda.\nDigalakkan jalankan update-safe-rm untuk menjana\nsenarai perlindungan paling sesuai untuk sistem semasa."
        MSG_HOMEPAGE="Laman projek:"
        MSG_INSTALLED_FILES="Fail dipasang:"
        MSG_DOWNLOADING="Memuat turun..."
        MSG_EXTRACTING="Mengekstrak..."
        MSG_UNSUPPORTED="Tidak disokong:"
        MSG_NEED_TOOLS="Ralat: alat diperlukan tiada."
        MSG_MANUAL_INSTALL="Sila pasang alat berikut secara manual kemudian cuba lagi:"
        MSG_DOWNLOAD_FAILED="Muat turun gagal"
        MSG_EXTRACT_FAILED="Ekstrak gagal"
        ;;
    hi_IN)
        MSG_INSTALL="safe-rm को इसमें स्थापित कर रहे हैं:"
        MSG_DONE="स्थापना पूर्ण।"
        MSG_UNINSTALL="safe-rm को हटा रहे हैं..."
        MSG_UNINSTALLED="स्थापना हटाना पूर्ण।"
        MSG_RELOGIN="कृपया पुनः लॉगिन करें, या चलाएँ:"
        MSG_TEST="परीक्षण:"
        MSG_NOT_ROOT="त्रुटि: root आवश्यक। sudo के साथ चलाएँ।"
        MSG_NO_FILE="त्रुटि: वर्तमान निर्देशिका में अनुपस्थित"
        MSG_ALREADY="safe-rm पहले से स्थापित है"
        MSG_UNINSTALL_HINT="हटाने के लिए चलाएँ:"
        MSG_PATH_SETUP="PATH सेटअप:"
        MSG_PATH_STANDARD="मानक:"
        MSG_PATH_OVERRIDE="यदि shell PATH को ओवरराइड करता है, तो shell कॉन्फ़िग में जोड़ें:"
        MSG_UPDATE_TITLE="सुरक्षा सूची अपडेट करें:"
        MSG_UPDATE_CONF="$SYSCONFDIR/safe-rm.conf अपडेट करें"
        MSG_UPDATE_DESC="नोट: डिफ़ॉल्ट संरक्षित पथ वितरण के अनुसार भिन्न होते हैं।\nबंडल किया गया safe-rm.conf सामान्य डिफ़ॉल्ट है और\nआपके सिस्टम से पूरी तरह मेल नहीं खा सकता।\nवर्तमान सिस्टम के लिए सबसे उपयुक्त सुरक्षा सूची\nबनाने के लिए update-safe-rm चलाने की सलाह दी जाती है।"
        MSG_HOMEPAGE="प्रोजेक्ट होमपेज:"
        MSG_INSTALLED_FILES="स्थापित फ़ाइलें:"
        MSG_DOWNLOADING="डाउनलोड हो रहा है..."
        MSG_EXTRACTING="निकाला जा रहा है..."
        MSG_UNSUPPORTED="असमर्थित:"
        MSG_NEED_TOOLS="त्रुटि: आवश्यक उपकरण अनुपस्थित।"
        MSG_MANUAL_INSTALL="कृपया निम्नलिखित उपकरण मैन्युअल रूप से स्थापित करें और पुनः प्रयास करें:"
        MSG_DOWNLOAD_FAILED="डाउनलोड विफल"
        MSG_EXTRACT_FAILED="निष्कर्षण विफल"
        ;;
    tr_TR)
        MSG_INSTALL="safe-rm şuraya kuruluyor:"
        MSG_DONE="Kurulum tamamlandı."
        MSG_UNINSTALL="safe-rm kaldırılıyor..."
        MSG_UNINSTALLED="Kaldırma tamamlandı."
        MSG_RELOGIN="Lütfen yeniden oturum açın veya çalıştırın:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Hata: root gerekli. sudo ile çalıştırın."
        MSG_NO_FILE="Hata: geçerli dizinde eksik"
        MSG_ALREADY="safe-rm zaten kurulu"
        MSG_UNINSTALL_HINT="Kaldırmak için çalıştırın:"
        MSG_PATH_SETUP="PATH ayarı:"
        MSG_PATH_STANDARD="Standart:"
        MSG_PATH_OVERRIDE="Kabuk PATH'i geçersiz kılıyorsa kabuk yapılandırmasına ekleyin:"
        MSG_UPDATE_TITLE="Koruma listesini güncelle:"
        MSG_UPDATE_CONF="$SYSCONFDIR/safe-rm.conf güncelle"
        MSG_UPDATE_DESC="Not: varsayılan korumalı yollar dağıtıma göre farklılık gösterir.\nPaketlenmiş safe-rm.conf genel bir varsayılandır ve\nsisteminizle tam olarak eşleşmeyebilir.\nMevcut sistem için en uygun koruma listesini oluşturmak\nüzere update-safe-rm çalıştırmanız önerilir."
        MSG_HOMEPAGE="Proje ana sayfası:"
        MSG_INSTALLED_FILES="Kurulu dosyalar:"
        MSG_DOWNLOADING="İndiriliyor..."
        MSG_EXTRACTING="Çıkarılıyor..."
        MSG_UNSUPPORTED="Desteklenmiyor:"
        MSG_NEED_TOOLS="Hata: gerekli araçlar eksik."
        MSG_MANUAL_INSTALL="Lütfen aşağıdaki araçları elle kurun ve yeniden deneyin:"
        MSG_DOWNLOAD_FAILED="İndirme başarısız"
        MSG_EXTRACT_FAILED="Çıkarma başarısız"
        ;;
    ru_RU)
        MSG_INSTALL="Установка safe-rm в"
        MSG_DONE="Установка завершена."
        MSG_UNINSTALL="Удаление safe-rm..."
        MSG_UNINSTALLED="Удаление завершено."
        MSG_RELOGIN="Пожалуйста, войдите снова или выполните:"
        MSG_TEST="Тест:"
        MSG_NOT_ROOT="Ошибка: требуются права root. Запустите через sudo."
        MSG_NO_FILE="Ошибка: отсутствует в текущем каталоге"
        MSG_ALREADY="safe-rm уже установлен"
        MSG_UNINSTALL_HINT="Для удаления выполните:"
        MSG_PATH_SETUP="Настройка PATH:"
        MSG_PATH_STANDARD="Стандарт:"
        MSG_PATH_OVERRIDE="Если оболочка переопределяет PATH, добавьте в её конфигурацию:"
        MSG_UPDATE_TITLE="Обновить список защиты:"
        MSG_UPDATE_CONF="обновить $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Примечание: пути защиты по умолчанию различаются в зависимости от дистрибутива.\nВходящий safe-rm.conf — это общее значение по умолчанию,\nоно может не полностью соответствовать вашей системе.\nРекомендуется запустить update-safe-rm, чтобы создать\nнаиболее подходящий список защиты для текущей системы."
        MSG_HOMEPAGE="Домашняя страница проекта:"
        MSG_INSTALLED_FILES="Установленные файлы:"
        MSG_DOWNLOADING="Загрузка..."
        MSG_EXTRACTING="Распаковка..."
        MSG_UNSUPPORTED="Не поддерживается:"
        MSG_NEED_TOOLS="Ошибка: отсутствуют необходимые инструменты."
        MSG_MANUAL_INSTALL="Пожалуйста, установите следующие инструменты вручную и повторите:"
        MSG_DOWNLOAD_FAILED="Ошибка загрузки"
        MSG_EXTRACT_FAILED="Ошибка распаковки"
        ;;
    uk_UA)
        MSG_INSTALL="Встановлення safe-rm у"
        MSG_DONE="Встановлення завершено."
        MSG_UNINSTALL="Видалення safe-rm..."
        MSG_UNINSTALLED="Видалення завершено."
        MSG_RELOGIN="Будь ласка, увійдіть знову або виконайте:"
        MSG_TEST="Тест:"
        MSG_NOT_ROOT="Помилка: потрібні права root. Запустіть через sudo."
        MSG_NO_FILE="Помилка: відсутній у поточному каталозі"
        MSG_ALREADY="safe-rm вже встановлено"
        MSG_UNINSTALL_HINT="Щоб видалити, виконайте:"
        MSG_PATH_SETUP="Налаштування PATH:"
        MSG_PATH_STANDARD="Стандарт:"
        MSG_PATH_OVERRIDE="Якщо оболонка перевизначає PATH, додайте до її конфігурації:"
        MSG_UPDATE_TITLE="Оновити список захисту:"
        MSG_UPDATE_CONF="оновити $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Примітка: шляхи захисту за замовчуванням відрізняються залежно від дистрибутива.\nВбудований safe-rm.conf — це загальне значення за замовчуванням,\nвін може не повністю відповідати вашій системі.\nРекомендується запустити update-safe-rm, щоб створити\nнайбільш відповідний список захисту для поточної системи."
        MSG_HOMEPAGE="Домашня сторінка проєкту:"
        MSG_INSTALLED_FILES="Встановлені файли:"
        MSG_DOWNLOADING="Завантаження..."
        MSG_EXTRACTING="Розпакування..."
        MSG_UNSUPPORTED="Не підтримується:"
        MSG_NEED_TOOLS="Помилка: відсутні необхідні інструменти."
        MSG_MANUAL_INSTALL="Будь ласка, встановіть наведені нижче інструменти вручну та повторіть:"
        MSG_DOWNLOAD_FAILED="Помилка завантаження"
        MSG_EXTRACT_FAILED="Помилка розпакування"
        ;;
    pl_PL)
        MSG_INSTALL="Instalowanie safe-rm do"
        MSG_DONE="Instalacja zakończona."
        MSG_UNINSTALL="Odinstalowywanie safe-rm..."
        MSG_UNINSTALLED="Odinstalowanie zakończone."
        MSG_RELOGIN="Zaloguj się ponownie lub uruchom:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Błąd: wymagane uprawnienia root. Uruchom przez sudo."
        MSG_NO_FILE="Błąd: brak w bieżącym katalogu"
        MSG_ALREADY="safe-rm jest już zainstalowany"
        MSG_UNINSTALL_HINT="Aby odinstalować, uruchom:"
        MSG_PATH_SETUP="Ustawienie PATH:"
        MSG_PATH_STANDARD="Standard:"
        MSG_PATH_OVERRIDE="Jeśli powłoka nadpisuje PATH, dodaj do konfiguracji powłoki:"
        MSG_UPDATE_TITLE="Zaktualizuj listę ochrony:"
        MSG_UPDATE_CONF="zaktualizuj $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Uwaga: domyślne ścieżki ochrony różnią się między dystrybucjami.\nDołączony safe-rm.conf to ogólna wartość domyślna i\nmoże nie w pełni odpowiadać Twojemu systemowi.\nZaleca się uruchomienie update-safe-rm w celu wygenerowania\nnajodpowiedniejszej listy ochrony dla bieżącego systemu."
        MSG_HOMEPAGE="Strona projektu:"
        MSG_INSTALLED_FILES="Zainstalowane pliki:"
        MSG_DOWNLOADING="Pobieranie..."
        MSG_EXTRACTING="Rozpakowywanie..."
        MSG_UNSUPPORTED="Nieobsługiwane:"
        MSG_NEED_TOOLS="Błąd: brak wymaganych narzędzi."
        MSG_MANUAL_INSTALL="Zainstaluj ręcznie następujące narzędzia i spróbuj ponownie:"
        MSG_DOWNLOAD_FAILED="Pobieranie nie powiodło się"
        MSG_EXTRACT_FAILED="Rozpakowanie nie powiodło się"
        ;;
    cs_CZ)
        MSG_INSTALL="Instalace safe-rm do"
        MSG_DONE="Instalace dokončena."
        MSG_UNINSTALL="Odinstalace safe-rm..."
        MSG_UNINSTALLED="Odinstalace dokončena."
        MSG_RELOGIN="Přihlaste se znovu nebo spusťte:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Chyba: vyžadováno root. Spusťte přes sudo."
        MSG_NO_FILE="Chyba: chybí v aktuálním adresáři"
        MSG_ALREADY="safe-rm je již nainstalován"
        MSG_UNINSTALL_HINT="Pro odinstalaci spusťte:"
        MSG_PATH_SETUP="Nastavení PATH:"
        MSG_PATH_STANDARD="Standard:"
        MSG_PATH_OVERRIDE="Pokud shell přepisuje PATH, přidejte do konfigurace shellu:"
        MSG_UPDATE_TITLE="Aktualizovat seznam ochrany:"
        MSG_UPDATE_CONF="aktualizovat $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Poznámka: výchozí chráněné cesty se liší podle distribuce.\nPřiložený safe-rm.conf je obecná výchozí hodnota a\nnemusí plně odpovídat vašemu systému.\nDoporučuje se spustit update-safe-rm a vygenerovat\ntak nejvhodnější seznam ochrany pro aktuální systém."
        MSG_HOMEPAGE="Domovská stránka projektu:"
        MSG_INSTALLED_FILES="Nainstalované soubory:"
        MSG_DOWNLOADING="Stahování..."
        MSG_EXTRACTING="Rozbalování..."
        MSG_UNSUPPORTED="Nepodporováno:"
        MSG_NEED_TOOLS="Chyba: chybí požadované nástroje."
        MSG_MANUAL_INSTALL="Nainstalujte prosím ručně následující nástroje a zkuste to znovu:"
        MSG_DOWNLOAD_FAILED="Stahování selhalo"
        MSG_EXTRACT_FAILED="Rozbalení selhalo"
        ;;
    hu_HU)
        MSG_INSTALL="safe-rm telepítése ide:"
        MSG_DONE="Telepítés kész."
        MSG_UNINSTALL="safe-rm eltávolítása..."
        MSG_UNINSTALLED="Eltávolítás kész."
        MSG_RELOGIN="Jelentkezzen be újra, vagy futtassa:"
        MSG_TEST="Teszt:"
        MSG_NOT_ROOT="Hiba: root szükséges. Futtassa sudo-val."
        MSG_NO_FILE="Hiba: hiányzik az aktuális könyvtárból"
        MSG_ALREADY="a safe-rm már telepítve van"
        MSG_UNINSTALL_HINT="Eltávolításhoz futtassa:"
        MSG_PATH_SETUP="PATH beállítás:"
        MSG_PATH_STANDARD="Szabvány:"
        MSG_PATH_OVERRIDE="Ha a shell felülírja a PATH-t, adja hozzá a shell konfigurációjához:"
        MSG_UPDATE_TITLE="Védelmi lista frissítése:"
        MSG_UPDATE_CONF="$SYSCONFDIR/safe-rm.conf frissítése"
        MSG_UPDATE_DESC="Megjegyzés: az alapértelmezett védett útvonalak disztribúciónként eltérnek.\nA mellékelt safe-rm.conf általános alapértelmezés, és\nnem feltétlenül egyezik teljesen a rendszerével.\nJavasolt az update-safe-rm futtatása a rendszerhez\nlegjobban illeszkedő védelmi lista létrehozásához."
        MSG_HOMEPAGE="Projekt honlapja:"
        MSG_INSTALLED_FILES="Telepített fájlok:"
        MSG_DOWNLOADING="Letöltés..."
        MSG_EXTRACTING="Kibontás..."
        MSG_UNSUPPORTED="Nem támogatott:"
        MSG_NEED_TOOLS="Hiba: hiányoznak a szükséges eszközök."
        MSG_MANUAL_INSTALL="Kérjük, telepítse kézzel a következő eszközöket, majd próbálja újra:"
        MSG_DOWNLOAD_FAILED="Letöltés sikertelen"
        MSG_EXTRACT_FAILED="Kibontás sikertelen"
        ;;
    ro_RO)
        MSG_INSTALL="Se instalează safe-rm în"
        MSG_DONE="Instalare finalizată."
        MSG_UNINSTALL="Se dezinstalează safe-rm..."
        MSG_UNINSTALLED="Dezinstalare finalizată."
        MSG_RELOGIN="Vă rugăm să vă reconectați sau rulați:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Eroare: este nevoie de root. Rulați cu sudo."
        MSG_NO_FILE="Eroare: lipsește din directorul curent"
        MSG_ALREADY="safe-rm este deja instalat"
        MSG_UNINSTALL_HINT="Pentru dezinstalare, rulați:"
        MSG_PATH_SETUP="Configurare PATH:"
        MSG_PATH_STANDARD="Standard:"
        MSG_PATH_OVERRIDE="Dacă shell-ul suprascrie PATH, adăugați în configurația shell-ului:"
        MSG_UPDATE_TITLE="Actualizați lista de protecție:"
        MSG_UPDATE_CONF="actualizați $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Notă: căile protejate implicite diferă între distribuții.\nsafe-rm.conf inclus este o valoare implicită generică și\ns-ar putea să nu se potrivească complet cu sistemul dvs.\nSe recomandă rularea update-safe-rm pentru a genera\nlista de protecție cea mai potrivită pentru sistemul curent."
        MSG_HOMEPAGE="Pagina proiectului:"
        MSG_INSTALLED_FILES="Fișiere instalate:"
        MSG_DOWNLOADING="Se descarcă..."
        MSG_EXTRACTING="Se extrage..."
        MSG_UNSUPPORTED="Nesuportat:"
        MSG_NEED_TOOLS="Eroare: lipsesc instrumentele necesare."
        MSG_MANUAL_INSTALL="Vă rugăm să instalați manual următoarele instrumente și să reîncercați:"
        MSG_DOWNLOAD_FAILED="Descărcare eșuată"
        MSG_EXTRACT_FAILED="Extragere eșuată"
        ;;
    el_GR)
        MSG_INSTALL="Εγκατάσταση safe-rm στο"
        MSG_DONE="Η εγκατάσταση ολοκληρώθηκε."
        MSG_UNINSTALL="Απεγκατάσταση safe-rm..."
        MSG_UNINSTALLED="Η απεγκατάσταση ολοκληρώθηκε."
        MSG_RELOGIN="Παρακαλώ συνδεθείτε ξανά ή εκτελέστε:"
        MSG_TEST="Δοκιμή:"
        MSG_NOT_ROOT="Σφάλμα: απαιτείται root. Εκτελέστε με sudo."
        MSG_NO_FILE="Σφάλμα: λείπει από τον τρέχοντα κατάλογο"
        MSG_ALREADY="το safe-rm είναι ήδη εγκατεστημένο"
        MSG_UNINSTALL_HINT="Για απεγκατάσταση, εκτελέστε:"
        MSG_PATH_SETUP="Ρύθμιση PATH:"
        MSG_PATH_STANDARD="Πρότυπο:"
        MSG_PATH_OVERRIDE="Αν το shell υπερκαλύπτει το PATH, προσθέστε στη διαμόρφωση του shell:"
        MSG_UPDATE_TITLE="Ενημέρωση λίστας προστασίας:"
        MSG_UPDATE_CONF="ενημέρωση $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Σημείωση: οι προεπιλεγμένες προστατευμένες διαδρομές διαφέρουν ανά διανομή.\nΤο συνοδευτικό safe-rm.conf είναι γενική προεπιλογή και\nμπορεί να μην ταιριάζει πλήρως με το σύστημά σας.\nΣυνιστάται να εκτελέσετε το update-safe-rm για να δημιουργήσετε\nτη λίστα προστασίας που ταιριάζει καλύτερα στο τρέχον σύστημα."
        MSG_HOMEPAGE="Ιστοσελίδα έργου:"
        MSG_INSTALLED_FILES="Εγκατεστημένα αρχεία:"
        MSG_DOWNLOADING="Λήψη..."
        MSG_EXTRACTING="Εξαγωγή..."
        MSG_UNSUPPORTED="Μη υποστηριζόμενο:"
        MSG_NEED_TOOLS="Σφάλμα: λείπουν τα απαιτούμενα εργαλεία."
        MSG_MANUAL_INSTALL="Εγκαταστήστε χειροκίνητα τα παρακάτω εργαλεία και δοκιμάστε ξανά:"
        MSG_DOWNLOAD_FAILED="Η λήψη απέτυχε"
        MSG_EXTRACT_FAILED="Η εξαγωγή απέτυχε"
        ;;
    de_DE)
        MSG_INSTALL="safe-rm wird installiert nach"
        MSG_DONE="Installation abgeschlossen."
        MSG_UNINSTALL="safe-rm wird deinstalliert..."
        MSG_UNINSTALLED="Deinstallation abgeschlossen."
        MSG_RELOGIN="Bitte neu anmelden oder ausführen:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Fehler: Root erforderlich. Mit sudo ausführen."
        MSG_NO_FILE="Fehler: fehlt im aktuellen Verzeichnis"
        MSG_ALREADY="safe-rm ist bereits installiert"
        MSG_UNINSTALL_HINT="Zum Deinstallieren ausführen:"
        MSG_PATH_SETUP="PATH-Einrichtung:"
        MSG_PATH_STANDARD="Standard:"
        MSG_PATH_OVERRIDE="Falls die Shell PATH überschreibt, zur Shell-Konfiguration hinzufügen:"
        MSG_UPDATE_TITLE="Schutzliste aktualisieren:"
        MSG_UPDATE_CONF="$SYSCONFDIR/safe-rm.conf aktualisieren"
        MSG_UPDATE_DESC="Hinweis: Standard-Schutzpfade unterscheiden sich je nach Distribution.\nDie mitgelieferte safe-rm.conf ist ein generischer Standard und\nentspricht möglicherweise nicht vollständig Ihrem System.\nEs wird empfohlen, update-safe-rm auszuführen, um die\nam besten passende Schutzliste für das aktuelle System zu erzeugen."
        MSG_HOMEPAGE="Projekt-Homepage:"
        MSG_INSTALLED_FILES="Installierte Dateien:"
        MSG_DOWNLOADING="Wird heruntergeladen..."
        MSG_EXTRACTING="Wird entpackt..."
        MSG_UNSUPPORTED="Nicht unterstützt:"
        MSG_NEED_TOOLS="Fehler: erforderliche Werkzeuge fehlen."
        MSG_MANUAL_INSTALL="Bitte installieren Sie die folgenden Werkzeuge manuell und versuchen Sie es erneut:"
        MSG_DOWNLOAD_FAILED="Download fehlgeschlagen"
        MSG_EXTRACT_FAILED="Entpacken fehlgeschlagen"
        ;;
    fr_FR)
        MSG_INSTALL="Installation de safe-rm dans"
        MSG_DONE="Installation terminée."
        MSG_UNINSTALL="Désinstallation de safe-rm..."
        MSG_UNINSTALLED="Désinstallation terminée."
        MSG_RELOGIN="Veuillez vous reconnecter ou exécuter :"
        MSG_TEST="Test :"
        MSG_NOT_ROOT="Erreur : root requis. Exécutez avec sudo."
        MSG_NO_FILE="Erreur : manquant dans le répertoire courant"
        MSG_ALREADY="safe-rm est déjà installé"
        MSG_UNINSTALL_HINT="Pour désinstaller, exécutez :"
        MSG_PATH_SETUP="Configuration de PATH :"
        MSG_PATH_STANDARD="Standard :"
        MSG_PATH_OVERRIDE="Si le shell remplace PATH, ajoutez à la configuration du shell :"
        MSG_UPDATE_TITLE="Mettre à jour la liste de protection :"
        MSG_UPDATE_CONF="mettre à jour $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Remarque : les chemins protégés par défaut diffèrent selon les distributions.\nLe fichier safe-rm.conf fourni est une valeur par défaut générique et\npeut ne pas correspondre entièrement à votre système.\nIl est recommandé d'exécuter update-safe-rm pour générer\nla liste de protection la plus adaptée au système actuel."
        MSG_HOMEPAGE="Page d'accueil du projet :"
        MSG_INSTALLED_FILES="Fichiers installés :"
        MSG_DOWNLOADING="Téléchargement..."
        MSG_EXTRACTING="Extraction..."
        MSG_UNSUPPORTED="Non pris en charge :"
        MSG_NEED_TOOLS="Erreur : outils requis manquants."
        MSG_MANUAL_INSTALL="Veuillez installer manuellement les outils suivants puis réessayer :"
        MSG_DOWNLOAD_FAILED="Échec du téléchargement"
        MSG_EXTRACT_FAILED="Échec de l'extraction"
        ;;
    es_ES|es_MX|es_AR)
        MSG_INSTALL="Instalando safe-rm en"
        MSG_DONE="Instalación completa."
        MSG_UNINSTALL="Desinstalando safe-rm..."
        MSG_UNINSTALLED="Desinstalación completa."
        MSG_RELOGIN="Vuelva a iniciar sesión o ejecute:"
        MSG_TEST="Prueba:"
        MSG_NOT_ROOT="Error: se requiere root. Ejecute con sudo."
        MSG_NO_FILE="Error: falta en el directorio actual"
        MSG_ALREADY="safe-rm ya está instalado"
        MSG_UNINSTALL_HINT="Para desinstalar, ejecute:"
        MSG_PATH_SETUP="Configuración de PATH:"
        MSG_PATH_STANDARD="Estándar:"
        MSG_PATH_OVERRIDE="Si el shell sobrescribe PATH, añada a la configuración del shell:"
        MSG_UPDATE_TITLE="Actualizar lista de protección:"
        MSG_UPDATE_CONF="actualizar $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Nota: las rutas protegidas por defecto varían entre distribuciones.\nEl safe-rm.conf incluido es un valor predeterminado genérico y\npuede no coincidir completamente con su sistema.\nSe recomienda ejecutar update-safe-rm para generar\nla lista de protección más adecuada para el sistema actual."
        MSG_HOMEPAGE="Página del proyecto:"
        MSG_INSTALLED_FILES="Archivos instalados:"
        MSG_DOWNLOADING="Descargando..."
        MSG_EXTRACTING="Extrayendo..."
        MSG_UNSUPPORTED="No soportado:"
        MSG_NEED_TOOLS="Error: faltan herramientas necesarias."
        MSG_MANUAL_INSTALL="Instale manualmente las siguientes herramientas y vuelva a intentarlo:"
        MSG_DOWNLOAD_FAILED="Descarga fallida"
        MSG_EXTRACT_FAILED="Extracción fallida"
        ;;
    pt_PT|pt_BR)
        MSG_INSTALL="Instalando safe-rm em"
        MSG_DONE="Instalação concluída."
        MSG_UNINSTALL="Desinstalando safe-rm..."
        MSG_UNINSTALLED="Desinstalação concluída."
        MSG_RELOGIN="Faça login novamente ou execute:"
        MSG_TEST="Teste:"
        MSG_NOT_ROOT="Erro: root necessário. Execute com sudo."
        MSG_NO_FILE="Erro: ausente no diretório atual"
        MSG_ALREADY="safe-rm já está instalado"
        MSG_UNINSTALL_HINT="Para desinstalar, execute:"
        MSG_PATH_SETUP="Configuração de PATH:"
        MSG_PATH_STANDARD="Padrão:"
        MSG_PATH_OVERRIDE="Se o shell substituir PATH, adicione à configuração do shell:"
        MSG_UPDATE_TITLE="Atualizar lista de proteção:"
        MSG_UPDATE_CONF="atualizar $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Nota: caminhos protegidos padrão variam entre distribuições.\nO safe-rm.conf incluído é um padrão genérico e\npode não corresponder totalmente ao seu sistema.\nRecomenda-se executar update-safe-rm para gerar\na lista de proteção mais adequada para o sistema atual."
        MSG_HOMEPAGE="Página do projeto:"
        MSG_INSTALLED_FILES="Arquivos instalados:"
        MSG_DOWNLOADING="Baixando..."
        MSG_EXTRACTING="Extraindo..."
        MSG_UNSUPPORTED="Não suportado:"
        MSG_NEED_TOOLS="Erro: ferramentas necessárias ausentes."
        MSG_MANUAL_INSTALL="Instale manualmente as seguintes ferramentas e tente novamente:"
        MSG_DOWNLOAD_FAILED="Falha no download"
        MSG_EXTRACT_FAILED="Falha na extração"
        ;;
    it_IT)
        MSG_INSTALL="Installazione di safe-rm in"
        MSG_DONE="Installazione completata."
        MSG_UNINSTALL="Disinstallazione di safe-rm..."
        MSG_UNINSTALLED="Disinstallazione completata."
        MSG_RELOGIN="Effettua di nuovo il login o esegui:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Errore: richiesto root. Esegui con sudo."
        MSG_NO_FILE="Errore: mancante nella directory corrente"
        MSG_ALREADY="safe-rm è già installato"
        MSG_UNINSTALL_HINT="Per disinstallare, esegui:"
        MSG_PATH_SETUP="Configurazione PATH:"
        MSG_PATH_STANDARD="Standard:"
        MSG_PATH_OVERRIDE="Se la shell sovrascrive PATH, aggiungi alla configurazione della shell:"
        MSG_UPDATE_TITLE="Aggiorna elenco di protezione:"
        MSG_UPDATE_CONF="aggiorna $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Nota: i percorsi protetti predefiniti variano tra distribuzioni.\nIl safe-rm.conf incluso è un valore predefinito generico e\npotrebbe non corrispondere completamente al tuo sistema.\nSi consiglia di eseguire update-safe-rm per generare\nl'elenco di protezione più adatto al sistema corrente."
        MSG_HOMEPAGE="Pagina del progetto:"
        MSG_INSTALLED_FILES="File installati:"
        MSG_DOWNLOADING="Download in corso..."
        MSG_EXTRACTING="Estrazione in corso..."
        MSG_UNSUPPORTED="Non supportato:"
        MSG_NEED_TOOLS="Errore: strumenti necessari mancanti."
        MSG_MANUAL_INSTALL="Installa manualmente i seguenti strumenti e riprova:"
        MSG_DOWNLOAD_FAILED="Download non riuscito"
        MSG_EXTRACT_FAILED="Estrazione non riuscita"
        ;;
    nl_NL)
        MSG_INSTALL="safe-rm installeren naar"
        MSG_DONE="Installatie voltooid."
        MSG_UNINSTALL="safe-rm verwijderen..."
        MSG_UNINSTALLED="Verwijderen voltooid."
        MSG_RELOGIN="Log opnieuw in of voer uit:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Fout: root vereist. Voer uit met sudo."
        MSG_NO_FILE="Fout: ontbreekt in huidige map"
        MSG_ALREADY="safe-rm is al geïnstalleerd"
        MSG_UNINSTALL_HINT="Om te verwijderen, voer uit:"
        MSG_PATH_SETUP="PATH-instelling:"
        MSG_PATH_STANDARD="Standaard:"
        MSG_PATH_OVERRIDE="Als de shell PATH overschrijft, voeg toe aan shell-configuratie:"
        MSG_UPDATE_TITLE="Beveiligingslijst bijwerken:"
        MSG_UPDATE_CONF="$SYSCONFDIR/safe-rm.conf bijwerken"
        MSG_UPDATE_DESC="Opmerking: standaard beveiligde paden verschillen per distributie.\nDe meegeleverde safe-rm.conf is een algemene standaard en\nkomt mogelijk niet volledig overeen met uw systeem.\nHet wordt aanbevolen update-safe-rm uit te voeren om\nde meest geschikte beveiligingslijst voor het huidige systeem te genereren."
        MSG_HOMEPAGE="Projecthomepage:"
        MSG_INSTALLED_FILES="Geïnstalleerde bestanden:"
        MSG_DOWNLOADING="Downloaden..."
        MSG_EXTRACTING="Uitpakken..."
        MSG_UNSUPPORTED="Niet ondersteund:"
        MSG_NEED_TOOLS="Fout: vereiste hulpmiddelen ontbreken."
        MSG_MANUAL_INSTALL="Installeer de volgende hulpmiddelen handmatig en probeer het opnieuw:"
        MSG_DOWNLOAD_FAILED="Download mislukt"
        MSG_EXTRACT_FAILED="Uitpakken mislukt"
        ;;
    sv_SE)
        MSG_INSTALL="Installerar safe-rm till"
        MSG_DONE="Installation klar."
        MSG_UNINSTALL="Avinstallerar safe-rm..."
        MSG_UNINSTALLED="Avinstallation klar."
        MSG_RELOGIN="Logga in igen eller kör:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Fel: root krävs. Kör med sudo."
        MSG_NO_FILE="Fel: saknas i aktuell katalog"
        MSG_ALREADY="safe-rm är redan installerat"
        MSG_UNINSTALL_HINT="För att avinstallera, kör:"
        MSG_PATH_SETUP="PATH-inställning:"
        MSG_PATH_STANDARD="Standard:"
        MSG_PATH_OVERRIDE="Om skalet åsidosätter PATH, lägg till i skalets konfiguration:"
        MSG_UPDATE_TITLE="Uppdatera skyddslista:"
        MSG_UPDATE_CONF="uppdatera $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Obs: standard skyddade sökvägar skiljer sig mellan distributioner.\nDen medföljande safe-rm.conf är en generisk standard och\nkanske inte matchar ditt system helt.\nDet rekommenderas att köra update-safe-rm för att generera\nden mest lämpliga skyddslistan för aktuellt system."
        MSG_HOMEPAGE="Projektets hemsida:"
        MSG_INSTALLED_FILES="Installerade filer:"
        MSG_DOWNLOADING="Laddar ner..."
        MSG_EXTRACTING="Packar upp..."
        MSG_UNSUPPORTED="Stöds inte:"
        MSG_NEED_TOOLS="Fel: nödvändiga verktyg saknas."
        MSG_MANUAL_INSTALL="Installera följande verktyg manuellt och försök igen:"
        MSG_DOWNLOAD_FAILED="Nedladdning misslyckades"
        MSG_EXTRACT_FAILED="Uppackning misslyckades"
        ;;
    nb_NO|nn_NO)
        MSG_INSTALL="Installerer safe-rm til"
        MSG_DONE="Installasjon fullført."
        MSG_UNINSTALL="Avinstallerer safe-rm..."
        MSG_UNINSTALLED="Avinstallering fullført."
        MSG_RELOGIN="Logg inn på nytt, eller kjør:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Feil: root kreves. Kjør med sudo."
        MSG_NO_FILE="Feil: mangler i gjeldende katalog"
        MSG_ALREADY="safe-rm er allerede installert"
        MSG_UNINSTALL_HINT="For å avinstallere, kjør:"
        MSG_PATH_SETUP="PATH-oppsett:"
        MSG_PATH_STANDARD="Standard:"
        MSG_PATH_OVERRIDE="Hvis skallet overstyrer PATH, legg til i skallkonfigurasjonen:"
        MSG_UPDATE_TITLE="Oppdater beskyttelsesliste:"
        MSG_UPDATE_CONF="oppdater $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Merk: standard beskyttede stier varierer mellom distribusjoner.\nDen medfølgende safe-rm.conf er en generisk standard og\nsamsvarer kanskje ikke helt med systemet ditt.\nDet anbefales å kjøre update-safe-rm for å generere\nden mest passende beskyttelseslisten for gjeldende system."
        MSG_HOMEPAGE="Prosjektets nettside:"
        MSG_INSTALLED_FILES="Installerte filer:"
        MSG_DOWNLOADING="Laster ned..."
        MSG_EXTRACTING="Pakker ut..."
        MSG_UNSUPPORTED="Ikke støttet:"
        MSG_NEED_TOOLS="Feil: nødvendige verktøy mangler."
        MSG_MANUAL_INSTALL="Installer følgende verktøy manuelt og prøv igjen:"
        MSG_DOWNLOAD_FAILED="Nedlasting mislyktes"
        MSG_EXTRACT_FAILED="Utpakking mislyktes"
        ;;
    da_DK)
        MSG_INSTALL="Installerer safe-rm til"
        MSG_DONE="Installation fuldført."
        MSG_UNINSTALL="Afinstallerer safe-rm..."
        MSG_UNINSTALLED="Afinstallation fuldført."
        MSG_RELOGIN="Log ind igen, eller kør:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Fejl: root påkrævet. Kør med sudo."
        MSG_NO_FILE="Fejl: mangler i aktuel mappe"
        MSG_ALREADY="safe-rm er allerede installeret"
        MSG_UNINSTALL_HINT="For at afinstallere, kør:"
        MSG_PATH_SETUP="PATH-opsætning:"
        MSG_PATH_STANDARD="Standard:"
        MSG_PATH_OVERRIDE="Hvis shell'en tilsidesætter PATH, føj til shell-konfigurationen:"
        MSG_UPDATE_TITLE="Opdater beskyttelsesliste:"
        MSG_UPDATE_CONF="opdater $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Bemærk: standard beskyttede stier varierer mellem distributioner.\nDen medfølgende safe-rm.conf er en generisk standard og\nmatcher måske ikke helt dit system.\nDet anbefales at køre update-safe-rm for at generere\nden mest passende beskyttelsesliste til det aktuelle system."
        MSG_HOMEPAGE="Projektets hjemmeside:"
        MSG_INSTALLED_FILES="Installerede filer:"
        MSG_DOWNLOADING="Downloader..."
        MSG_EXTRACTING="Udpakker..."
        MSG_UNSUPPORTED="Ikke understøttet:"
        MSG_NEED_TOOLS="Fejl: nødvendige værktøjer mangler."
        MSG_MANUAL_INSTALL="Installer følgende værktøjer manuelt og prøv igen:"
        MSG_DOWNLOAD_FAILED="Download mislykkedes"
        MSG_EXTRACT_FAILED="Udpakning mislykkedes"
        ;;
    fi_FI)
        MSG_INSTALL="Asennetaan safe-rm kohteeseen"
        MSG_DONE="Asennus valmis."
        MSG_UNINSTALL="Poistetaan safe-rm..."
        MSG_UNINSTALLED="Poisto valmis."
        MSG_RELOGIN="Kirjaudu uudelleen tai suorita:"
        MSG_TEST="Testi:"
        MSG_NOT_ROOT="Virhe: root vaaditaan. Suorita sudolla."
        MSG_NO_FILE="Virhe: puuttuu nykyisestä hakemistosta"
        MSG_ALREADY="safe-rm on jo asennettu"
        MSG_UNINSTALL_HINT="Poistaaksesi suorita:"
        MSG_PATH_SETUP="PATH-asetus:"
        MSG_PATH_STANDARD="Vakio:"
        MSG_PATH_OVERRIDE="Jos komentotulkki ohittaa PATHin, lisää komentotulkin asetuksiin:"
        MSG_UPDATE_TITLE="Päivitä suojauslista:"
        MSG_UPDATE_CONF="päivitä $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Huom: oletussuojapolut vaihtelevat jakelukohtaisesti.\nMukana tuleva safe-rm.conf on yleinen oletusarvo, eikä\nse välttämättä vastaa täysin järjestelmääsi.\nOn suositeltavaa suorittaa update-safe-rm, joka luo\nnykyiselle järjestelmälle sopivimman suojauslistan."
        MSG_HOMEPAGE="Projektin kotisivu:"
        MSG_INSTALLED_FILES="Asennetut tiedostot:"
        MSG_DOWNLOADING="Ladataan..."
        MSG_EXTRACTING="Puretaan..."
        MSG_UNSUPPORTED="Ei tuettu:"
        MSG_NEED_TOOLS="Virhe: tarvittavat työkalut puuttuvat."
        MSG_MANUAL_INSTALL="Asenna seuraavat työkalut manuaalisesti ja yritä uudelleen:"
        MSG_DOWNLOAD_FAILED="Lataus epäonnistui"
        MSG_EXTRACT_FAILED="Purku epäonnistui"
        ;;
    ar_SA|ar_EG)
        MSG_INSTALL="جارٍ تثبيت safe-rm في"
        MSG_DONE="اكتمل التثبيت."
        MSG_UNINSTALL="جارٍ إلغاء تثبيت safe-rm..."
        MSG_UNINSTALLED="اكتمل إلغاء التثبيت."
        MSG_RELOGIN="الرجاء تسجيل الدخول مرة أخرى، أو شغّل:"
        MSG_TEST="اختبار:"
        MSG_NOT_ROOT="خطأ: مطلوب صلاحيات root. شغّل باستخدام sudo."
        MSG_NO_FILE="خطأ: مفقود في الدليل الحالي"
        MSG_ALREADY="safe-rm مُثبّت بالفعل"
        MSG_UNINSTALL_HINT="لإلغاء التثبيت، شغّل:"
        MSG_PATH_SETUP="إعداد PATH:"
        MSG_PATH_STANDARD="قياسي:"
        MSG_PATH_OVERRIDE="إذا كانت الصدفة تتجاوز PATH، أضف إلى إعدادات الصدفة:"
        MSG_UPDATE_TITLE="تحديث قائمة الحماية:"
        MSG_UPDATE_CONF="تحديث $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="ملاحظة: تختلف مسارات الحماية الافتراضية بين التوزيعات.\nملف safe-rm.conf المرفق هو قيمة افتراضية عامة وقد\nلا يتوافق تمامًا مع نظامك.\nيوصى بتشغيل update-safe-rm لإنشاء\nقائمة الحماية الأنسب للنظام الحالي."
        MSG_HOMEPAGE="الصفحة الرئيسية للمشروع:"
        MSG_INSTALLED_FILES="الملفات المثبتة:"
        MSG_DOWNLOADING="جارٍ التنزيل..."
        MSG_EXTRACTING="جارٍ الاستخراج..."
        MSG_UNSUPPORTED="غير مدعوم:"
        MSG_NEED_TOOLS="خطأ: الأدوات المطلوبة مفقودة."
        MSG_MANUAL_INSTALL="الرجاء تثبيت الأدوات التالية يدويًا ثم إعادة المحاولة:"
        MSG_DOWNLOAD_FAILED="فشل التنزيل"
        MSG_EXTRACT_FAILED="فشل الاستخراج"
        ;;
    he_IL)
        MSG_INSTALL="מתקין את safe-rm אל"
        MSG_DONE="ההתקנה הושלמה."
        MSG_UNINSTALL="מסיר את safe-rm..."
        MSG_UNINSTALLED="ההסרה הושלמה."
        MSG_RELOGIN="אנא התחבר מחדש, או הרץ:"
        MSG_TEST="בדיקה:"
        MSG_NOT_ROOT="שגיאה: נדרש root. הרץ עם sudo."
        MSG_NO_FILE="שגיאה: חסר בספרייה הנוכחית"
        MSG_ALREADY="safe-rm כבר מותקן"
        MSG_UNINSTALL_HINT="להסרה, הרץ:"
        MSG_PATH_SETUP="הגדרת PATH:"
        MSG_PATH_STANDARD="תקני:"
        MSG_PATH_OVERRIDE="אם ה-shell דורס את PATH, הוסף להגדרות ה-shell:"
        MSG_UPDATE_TITLE="עדכן רשימת הגנה:"
        MSG_UPDATE_CONF="עדכן $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="הערה: נתיבי הגנה ברירת מחדל שונים בין הפצות.\nהקובץ safe-rm.conf המצורף הוא ברירת מחדל כללית ועשוי\nלא להתאים באופן מלא למערכת שלך.\nמומלץ להריץ update-safe-rm כדי ליצור\nאת רשימת ההגנה המתאימה ביותר למערכת הנוכחית."
        MSG_HOMEPAGE="דף הבית של הפרויקט:"
        MSG_INSTALLED_FILES="קבצים מותקנים:"
        MSG_DOWNLOADING="מוריד..."
        MSG_EXTRACTING="מחלץ..."
        MSG_UNSUPPORTED="לא נתמך:"
        MSG_NEED_TOOLS="שגיאה: חסרים כלים נדרשים."
        MSG_MANUAL_INSTALL="אנא התקן ידנית את הכלים הבאים ונסה שוב:"
        MSG_DOWNLOAD_FAILED="ההורדה נכשלה"
        MSG_EXTRACT_FAILED="החילוץ נכשל"
        ;;
    fa_IR)
        MSG_INSTALL="در حال نصب safe-rm در"
        MSG_DONE="نصب کامل شد."
        MSG_UNINSTALL="در حال حذف نصب safe-rm..."
        MSG_UNINSTALLED="حذف نصب کامل شد."
        MSG_RELOGIN="لطفاً دوباره وارد شوید یا اجرا کنید:"
        MSG_TEST="تست:"
        MSG_NOT_ROOT="خطا: دسترسی root لازم است. با sudo اجرا کنید."
        MSG_NO_FILE="خطا: در پوشه فعلی موجود نیست"
        MSG_ALREADY="safe-rm قبلاً نصب شده است"
        MSG_UNINSTALL_HINT="برای حذف نصب، اجرا کنید:"
        MSG_PATH_SETUP="تنظیم PATH:"
        MSG_PATH_STANDARD="استاندارد:"
        MSG_PATH_OVERRIDE="اگر پوسته PATH را بازنویسی می‌کند، به پیکربندی پوسته اضافه کنید:"
        MSG_UPDATE_TITLE="به‌روزرسانی لیست محافظت:"
        MSG_UPDATE_CONF="به‌روزرسانی $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="توجه: مسیرهای محافظت پیش‌فرض بین توزیع‌ها متفاوت است.\nفایل safe-rm.conf همراه یک مقدار پیش‌فرض عمومی است و\nممکن است کاملاً با سیستم شما مطابقت نداشته باشد.\nتوصیه می‌شود update-safe-rm را اجرا کنید تا\nمناسب‌ترین لیست محافظت برای سیستم فعلی ایجاد شود."
        MSG_HOMEPAGE="صفحه اصلی پروژه:"
        MSG_INSTALLED_FILES="فایل‌های نصب‌شده:"
        MSG_DOWNLOADING="در حال دانلود..."
        MSG_EXTRACTING="در حال استخراج..."
        MSG_UNSUPPORTED="پشتیبانی نمی‌شود:"
        MSG_NEED_TOOLS="خطا: ابزارهای لازم موجود نیستند."
        MSG_MANUAL_INSTALL="لطفاً ابزارهای زیر را به‌صورت دستی نصب کنید و دوباره امتحان کنید:"
        MSG_DOWNLOAD_FAILED="دانلود ناموفق"
        MSG_EXTRACT_FAILED="استخراج ناموفق"
        ;;
    bn_BD)
        MSG_INSTALL="safe-rm ইনস্টল করা হচ্ছে"
        MSG_DONE="ইনস্টল সম্পন্ন হয়েছে।"
        MSG_UNINSTALL="safe-rm আনইনস্টল করা হচ্ছে..."
        MSG_UNINSTALLED="আনইনস্টল সম্পন্ন হয়েছে।"
        MSG_RELOGIN="অনুগ্রহ করে আবার লগইন করুন, অথবা চালান:"
        MSG_TEST="পরীক্ষা:"
        MSG_NOT_ROOT="ত্রুটি: root প্রয়োজন। sudo দিয়ে চালান।"
        MSG_NO_FILE="ত্রুটি: বর্তমান ডিরেক্টরিতে নেই"
        MSG_ALREADY="safe-rm ইতিমধ্যে ইনস্টল করা আছে"
        MSG_UNINSTALL_HINT="আনইনস্টল করতে চালান:"
        MSG_PATH_SETUP="PATH সেটআপ:"
        MSG_PATH_STANDARD="স্ট্যান্ডার্ড:"
        MSG_PATH_OVERRIDE="যদি শেল PATH ওভাররাইড করে, শেল কনফিগে যোগ করুন:"
        MSG_UPDATE_TITLE="সুরক্ষা তালিকা আপডেট করুন:"
        MSG_UPDATE_CONF="$SYSCONFDIR/safe-rm.conf আপডেট করুন"
        MSG_UPDATE_DESC="নোট: ডিফল্ট সুরক্ষিত পাথ ডিস্ট্রিবিউশন অনুযায়ী ভিন্ন।\nবান্ডল করা safe-rm.conf একটি সাধারণ ডিফল্ট এবং\nআপনার সিস্টেমের সাথে সম্পূর্ণ নাও মিলতে পারে।\nবর্তমান সিস্টেমের জন্য সবচেয়ে উপযুক্ত সুরক্ষা তালিকা\nতৈরি করতে update-safe-rm চালানোর পরামর্শ দেওয়া হয়।"
        MSG_HOMEPAGE="প্রকল্পের হোমপেজ:"
        MSG_INSTALLED_FILES="ইনস্টল করা ফাইল:"
        MSG_DOWNLOADING="ডাউনলোড হচ্ছে..."
        MSG_EXTRACTING="এক্সট্র্যাক্ট করা হচ্ছে..."
        MSG_UNSUPPORTED="অসমর্থিত:"
        MSG_NEED_TOOLS="ত্রুটি: প্রয়োজনীয় টুল অনুপস্থিত।"
        MSG_MANUAL_INSTALL="অনুগ্রহ করে নিচের টুলগুলি ম্যানুয়ালি ইনস্টল করে আবার চেষ্টা করুন:"
        MSG_DOWNLOAD_FAILED="ডাউনলোড ব্যর্থ"
        MSG_EXTRACT_FAILED="এক্সট্র্যাকশন ব্যর্থ"
        ;;
    sk_SK)
        MSG_INSTALL="Inštalácia safe-rm do"
        MSG_DONE="Inštalácia dokončená."
        MSG_UNINSTALL="Odinštalácia safe-rm..."
        MSG_UNINSTALLED="Odinštalácia dokončená."
        MSG_RELOGIN="Prihláste sa znova alebo spustite:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Chyba: vyžaduje sa root. Spustite cez sudo."
        MSG_NO_FILE="Chyba: chýba v aktuálnom adresári"
        MSG_ALREADY="safe-rm je už nainštalovaný"
        MSG_UNINSTALL_HINT="Pre odinštalovanie spustite:"
        MSG_PATH_SETUP="Nastavenie PATH:"
        MSG_PATH_STANDARD="Štandard:"
        MSG_PATH_OVERRIDE="Ak shell prepisuje PATH, pridajte do konfigurácie shellu:"
        MSG_UPDATE_TITLE="Aktualizovať zoznam ochrany:"
        MSG_UPDATE_CONF="aktualizovať $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Poznámka: predvolené chránené cesty sa líšia podľa distribúcie.\nPriložený safe-rm.conf je všeobecná predvolená hodnota a\nnemusí úplne zodpovedať vášmu systému.\nOdporúča sa spustiť update-safe-rm a vygenerovať\ntak najvhodnejší zoznam ochrany pre aktuálny systém."
        MSG_HOMEPAGE="Domovská stránka projektu:"
        MSG_INSTALLED_FILES="Nainštalované súbory:"
        MSG_DOWNLOADING="Sťahovanie..."
        MSG_EXTRACTING="Rozbaľovanie..."
        MSG_UNSUPPORTED="Nepodporované:"
        MSG_NEED_TOOLS="Chyba: chýbajú požadované nástroje."
        MSG_MANUAL_INSTALL="Nainštalujte ručne nasledujúce nástroje a skúste znova:"
        MSG_DOWNLOAD_FAILED="Sťahovanie zlyhalo"
        MSG_EXTRACT_FAILED="Rozbalenie zlyhalo"
        ;;
    *)
        MSG_INSTALL="Installing safe-rm to"
        MSG_DONE="Installation complete."
        MSG_UNINSTALL="Uninstalling safe-rm..."
        MSG_UNINSTALLED="Uninstallation complete."
        MSG_RELOGIN="Please re-login, or run:"
        MSG_TEST="Test:"
        MSG_NOT_ROOT="Error: root required. Run with sudo."
        MSG_NO_FILE="Error: missing in current directory"
        MSG_ALREADY="safe-rm is already installed"
        MSG_UNINSTALL_HINT="To uninstall, run:"
        MSG_PATH_SETUP="PATH setup:"
        MSG_PATH_STANDARD="Standard:"
        MSG_PATH_OVERRIDE="If your shell overrides PATH, add to your shell config:"
        MSG_UPDATE_TITLE="Update protection list:"
        MSG_UPDATE_CONF="update $SYSCONFDIR/safe-rm.conf"
        MSG_UPDATE_DESC="Note: default protected paths differ across distributions.\nThe bundled safe-rm.conf is a generic default and\nmay not fully match your system.\nIt is recommended to run update-safe-rm to generate\nthe most suitable protection list for the current system."
        MSG_HOMEPAGE="Project homepage:"
        MSG_INSTALLED_FILES="Installed files:"
        MSG_DOWNLOADING="Downloading..."
        MSG_EXTRACTING="Extracting..."
        MSG_UNSUPPORTED="Unsupported:"
        MSG_NEED_TOOLS="Error: missing required tools."
        MSG_MANUAL_INSTALL="Please install the following tools manually and retry:"
        MSG_DOWNLOAD_FAILED="Download failed"
        MSG_EXTRACT_FAILED="Extract failed"
        ;;
esac

# Output helpers 
error() {
    echo "${RED}${1}${NC}" >&2
    exit 1
}

info() {
    echo "${GREEN}${1}${NC}"
}

warn() {
    echo "${YELLOW}${1}${NC}"
}

# Root check 
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "$MSG_NOT_ROOT"
    fi
}

# Local file check 
check_files() {
    for f in safe-rm safe-rm.conf safe-rm.sh update-safe-rm safe-rm.1; do
        if [ ! -f "$f" ]; then
            error "$MSG_NO_FILE $f"
        fi
    done
}

# Already installed check 
check_installed() {
    if [ -f "$BINDIR/safe-rm" ]; then
        warn "$MSG_ALREADY: $BINDIR/safe-rm"
        echo ""
        echo "$MSG_UNINSTALL_HINT"
        echo "  sh install.sh --uninstall"
        exit 0
    fi
}

# Online install: check required tools 
check_tools() {
    have_cmd() {
        command -v "$1" >/dev/null 2>&1
    }

    # Downloader: curl only
    if have_cmd curl; then
        DOWNLOAD="curl"
    else
        DOWNLOAD=""
    fi

    # tar is required
    HAVE_TAR=0
    have_cmd tar && HAVE_TAR=1

    # Both available: OK
    if [ -n "$DOWNLOAD" ] && [ "$HAVE_TAR" -eq 1 ]; then
        return 0
    fi

    # Missing: tell the user to install manually
    echo "${RED}${MSG_NEED_TOOLS}${NC}" >&2

    MISSING=""
    [ -z "$DOWNLOAD" ] && MISSING="$MISSING curl"
    [ "$HAVE_TAR" -eq 0 ] && MISSING="$MISSING tar"
    echo "  missing:${MISSING}" >&2
    echo "" >&2

    echo "${YELLOW}${MSG_MANUAL_INSTALL}${NC}" >&2
    echo "" >&2
    echo "  Debian/Ubuntu : apt-get install -y curl tar" >&2
    echo "  Fedora/RHEL   : dnf install -y curl tar" >&2
    echo "  CentOS        : yum install -y curl tar" >&2
    echo "  Arch          : pacman -Sy --noconfirm curl tar" >&2
    echo "  openSUSE      : zypper install -y curl tar" >&2
    echo "  Alpine        : apk add --no-cache curl tar" >&2
    echo "  FreeBSD       : pkg install -y curl tar" >&2
    echo "  macOS         : brew install curl" >&2
    echo "" >&2

    exit 1
}

# Helper: detect musl
is_musl() {
    [ -e /lib/ld-musl-*.so.1 ]
}

# Helper: check if glibc >= 2.32
has_glibc_min_2_32() {
    # If not Linux, assume true (macOS uses libSystem, FreeBSD uses its own libc)
    if [ "$(uname -s)" != "Linux" ]; then
        return 0
    fi

    # No ldd -> can't detect
    if ! command -v ldd >/dev/null 2>&1; then
        return 1
    fi

    GLIBC_VER=$(ldd --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+$')
    if [ -z "$GLIBC_VER" ]; then
        return 1
    fi

    MAJOR=${GLIBC_VER%%.*}
    MINOR=${GLIBC_VER#*.}

    if [ "$MAJOR" -gt 2 ]; then
        return 0
    fi
    if [ "$MAJOR" -eq 2 ] && [ "$MINOR" -ge 32 ]; then
        return 0
    fi
    return 1
}

# Online install: detect platform
detect_platform() {
    OS=$(uname -s)
    ARCH=$(uname -m)

    case "$ARCH" in
        amd64|x86_64)  ARCH="x86_64" ;;
        arm64|aarch64) ARCH="aarch64" ;;
        loongarch64|loong64) ARCH="loongarch64" ;;
    esac

    case "${OS}-${ARCH}" in
        Linux-x86_64)
            if is_musl; then
                PKG="safe-rm-v${VERSION}-linux-x86_64-musl.tar.gz"
            elif has_glibc_min_2_32; then
                PKG="safe-rm-v${VERSION}-linux-x86_64-gnu.tar.gz"
            else
                # Old glibc (e.g., CentOS 7, Fedora 32): use musl static build
                PKG="safe-rm-v${VERSION}-linux-x86_64-musl.tar.gz"
            fi
            ;;
        Linux-aarch64)
            if is_musl; then
                PKG="safe-rm-v${VERSION}-linux-aarch64-musl.tar.gz"
            elif has_glibc_min_2_32; then
                PKG="safe-rm-v${VERSION}-linux-aarch64-gnu.tar.gz"
            else
                # Old glibc: use musl static build
                PKG="safe-rm-v${VERSION}-linux-aarch64-musl.tar.gz"
            fi
            ;;
        Linux-loongarch64)
            PKG="safe-rm-v${VERSION}-linux-loongarch64-gnu.tar.gz"
            ;;
        FreeBSD-x86_64)
            PKG="safe-rm-v${VERSION}-freebsd-x86_64.tar.gz"
            ;;
        Darwin-x86_64)
            PKG="safe-rm-v${VERSION}-macos-x86_64.tar.gz"
            ;;
        Darwin-aarch64)
            PKG="safe-rm-v${VERSION}-macos-aarch64.tar.gz"
            ;;
        *)
            error "$MSG_UNSUPPORTED ${OS} ${ARCH}"
            ;;
    esac

    URL="${BASE_URL}/${PKG}"
    DIR=$(basename "$PKG" .tar.gz)

    info "OS:   ${OS}"
    info "ARCH: ${ARCH}"
    info "PKG:  ${PKG}"
}

# Online install: download 
download() {
    TMPDIR=$(mktemp -d)
    cd "$TMPDIR"

    info "$MSG_DOWNLOADING"
    info "$URL"

    curl -fL --progress-bar -o "$PKG" "$URL" || {
        cd /
        rm -rf "$TMPDIR"
        error "$MSG_DOWNLOAD_FAILED"
    }
}

# Online install: extract 
extract() {
    info "$MSG_EXTRACTING"
    tar xzf "$PKG" || {
        cd /
        rm -rf "$TMPDIR"
        error "$MSG_EXTRACT_FAILED"
    }
    cd "$DIR"
}

# Local install from current directory 
install_from_cwd() {
    check_files
    check_installed

    info "$MSG_INSTALL $PREFIX ..."

    # 1. Binary
    install -d "$BINDIR"
    install -m 755 safe-rm "$BINDIR/safe-rm"

    # 2. Config
    install -d "$SYSCONFDIR"
    if [ ! -f "$SYSCONFDIR/safe-rm.conf" ]; then
        install -m 644 safe-rm.conf "$SYSCONFDIR/safe-rm.conf"
    fi

    # 3. PATH script
    install -d "$PROFILEDIR"
    install -m 644 safe-rm.sh "$PROFILEDIR/safe-rm.sh"

    # 4. Symlink
    install -d "$SYMLINKDIR"
    ln -sf "$BINDIR/safe-rm" "$SYMLINKDIR/rm"

    # 5. Update script
    install -m 755 update-safe-rm "$BINDIR/update-safe-rm"

    # 6. Man page
    install -d "$MANDIR"
    install -m 644 safe-rm.1 "$MANDIR/safe-rm.1"

    # 7. Documentation
    install -d "$DOCDIR"
    for f in README.md INSTALL COPYING Changes install.sh; do
        if [ -f "$f" ]; then
            install -m 644 "$f" "$DOCDIR/"
        fi
    done

    info "$MSG_DONE"
    echo ""

    # 1. Installed files
    echo "$MSG_INSTALLED_FILES"
    echo "  $BINDIR/safe-rm"
    echo "  $SYMLINKDIR/rm"
    echo "  $SYSCONFDIR/safe-rm.conf"
    echo "  $PROFILEDIR/safe-rm.sh"
    echo "  $BINDIR/update-safe-rm"
    echo "  $MANDIR/safe-rm.1"
    echo "  $DOCDIR/"
    if [ -d "$DOCDIR" ]; then
        for f in "$DOCDIR"/*; do
            [ -e "$f" ] && echo "    $(basename "$f")"
        done
    fi
    echo ""

    # 2. Update protection list
    echo "$MSG_UPDATE_TITLE"
    echo ""
    echo "  update-safe-rm              # $MSG_UPDATE_CONF"
    echo ""
    printf "%b\n" "$MSG_UPDATE_DESC"
    echo ""

    # 3. Re-login hint
    echo "$MSG_RELOGIN"
    echo "  . $PROFILEDIR/safe-rm.sh"
    echo ""

    # 4. Test
    echo "$MSG_TEST"
    echo "  rm -rf /tmp"
    echo "  # safe-rm: Skipping /tmp."
    echo ""

    # 5. PATH setup
    echo "$MSG_PATH_SETUP"
    echo "  $MSG_PATH_STANDARD $PROFILEDIR/safe-rm.sh"
    echo "  $MSG_PATH_OVERRIDE"
    echo ""
    echo "    bash: echo 'export PATH=\"$SYMLINKDIR:\$PATH\"' >> ~/.bashrc"
    echo "    zsh:  echo 'export PATH=\"$SYMLINKDIR:\$PATH\"' >> ~/.zshrc"
    echo "    sh:   echo 'PATH=\"$SYMLINKDIR:\$PATH\"' >> ~/.profile"
    echo "    csh:  echo 'set path = ($SYMLINKDIR \$path)' >> ~/.cshrc"
    echo ""

    # 6. Project homepage
    echo "$MSG_HOMEPAGE $HOMEPAGE"
    echo ""

    # 7. safe-rm help
    if [ -x "$BINDIR/safe-rm" ]; then
        "$BINDIR/safe-rm" --help
    fi
}

# Install 
do_install() {
    check_root

    # Case 1: complete local files in current directory -> local install
    if [ -f "safe-rm" ] && [ -f "safe-rm.conf" ] && [ -f "safe-rm.sh" ] \
        && [ -f "update-safe-rm" ] && [ -f "safe-rm.1" ]; then
        install_from_cwd
        return
    fi

    # Case 2: online install
    check_installed
    check_tools
    detect_platform
    download
    extract

    # After extraction, reuse the local install logic
    if [ -f "safe-rm" ] && [ -f "safe-rm.conf" ] && [ -f "safe-rm.sh" ] \
        && [ -f "update-safe-rm" ] && [ -f "safe-rm.1" ]; then
        install_from_cwd

        cd /
        rm -rf "$TMPDIR"
    else
        cd /
        rm -rf "$TMPDIR"
        error "$MSG_NO_FILE safe-rm"
    fi
}

# Uninstall 
do_uninstall() {
    check_root

    info "$MSG_UNINSTALL"

    # 1. Binaries
    rm -f "$BINDIR/safe-rm"
    rm -f "$BINDIR/update-safe-rm"

    # 2. Config
    rm -f "$SYSCONFDIR/safe-rm.conf"

    # 3. PATH script
    rm -f "$PROFILEDIR/safe-rm.sh"

    # 4. Symlink directory
    rm -rf "$SYMLINKDIR"
    rmdir "$PREFIX/share/safe-rm" 2>/dev/null || true

    # 5. Man page
    rm -f "$MANDIR/safe-rm.1"

    # 6. Documentation
    rm -rf "$DOCDIR"

    # 7. Legacy paths (for compatibility across versions)
    rm -f /etc/profile.d/safe-rm.sh
    rm -f /usr/local/etc/profile.d/safe-rm.sh
    rm -f /etc/safe-rm.conf
    rm -f /usr/local/etc/safe-rm.conf

    info "$MSG_UNINSTALLED"
}

# Usage 
usage() {
    cat << EOF
safe-rm installer (integrated)

Usage: $0 [OPTIONS]

Options:
  -h, --help        Show this help
  -u, --uninstall   Uninstall safe-rm

Environment:
  VERSION      Version to install for online mode (default: ${VERSION})
  PREFIX       Install prefix (default: /usr/local)
  SYSCONFDIR   Config dir (default: /etc on Linux, /usr/local/etc on FreeBSD/macOS)
  MANDIR       Man dir (default: \$PREFIX/share/man/man1)
  DOCDIR       Doc dir (default: \$PREFIX/share/doc/safe-rm)

Local install:
  sh install.sh
  PREFIX=/opt/safe-rm sudo ./install.sh
  sh install.sh --uninstall

Online install:
  curl -fsSL https://raw.githubusercontent.com/${REPO}/master/install.sh | sudo sh
  VERSION=1.1.0 sudo sh install.sh
  sudo sh install.sh --uninstall

Homepage: $HOMEPAGE
EOF
}

# Main 
case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;
    -u|--uninstall)
        do_uninstall
        ;;
    "")
        do_install
        ;;
    *)
        usage
        exit 1
        ;;
esac