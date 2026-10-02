<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Yoyo X Yaya - Steam Clone</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { background-color: #1b2838; color: #c7d5e0; font-family: Arial, Helvetica, sans-serif; }
        .sidebar { background-color: #171a21; }
        .panel-bg { background-color: rgba(0, 0, 0, 0.4); }
        .game-card { background-color: #1b2838; box-shadow: 0 4px 8px rgba(0,0,0,0.3); transition: transform 0.2s; }
        .game-card:hover { transform: scale(1.02); }
        .steam-btn { background: linear-gradient(to right, #75b022 5%, #588a1b 95%); color: #d2efa9; text-shadow: 1px 1px rgba(0,0,0,0.3); }
        .steam-btn:hover { background: linear-gradient(to right, #8ed029 5%, #6aa614 95%); color: white; }
        .nav-active { background-color: rgba(255, 255, 255, 0.1); border-right: 4px solid #66c0f4; color: white; }
        .input-field { background-color: #323e4c; border: 1px solid #171a21; color: white; }
        .input-field:focus { outline: none; border-color: #66c0f4; }
    </style>
</head>
<body class="overflow-hidden select-none">

    <!-- شاشة تسجيل الدخول -->
    <div id="login-screen" class="absolute inset-0 z-[60] flex items-center justify-center p-4 bg-[#1b2838]">
        <div class="bg-[#171a21] w-full max-w-md p-8 rounded shadow-2xl border border-gray-800">
            <h1 class="text-4xl font-bold text-center text-white mb-2">Yoyo X <span class="text-blue-400">Yaya</span></h1>
            <p class="text-center text-gray-400 mb-8">سجل دخولك (yoyo أو yaya للأدمن - أي اسم آخر لليوزر)</p>
            <form id="loginForm" class="space-y-4">
                <input type="text" id="usernameInput" required class="input-field w-full p-3 rounded" placeholder="اسم المستخدم (مثال: ahmed)">
                <input type="password" required class="input-field w-full p-3 rounded" placeholder="كلمة المرور">
                <button type="submit" class="w-full py-3 rounded font-bold text-white bg-blue-600 hover:bg-blue-500">تسجيل الدخول</button>
            </form>
        </div>
    </div>

    <!-- نافذة الدفع بالفيزا ( Paymob Integration Ready ) -->
    <div id="payment-modal" class="hidden absolute inset-0 z-[70] bg-black bg-opacity-80 flex items-center justify-center p-4">
        <div class="bg-[#171a21] w-full max-w-md p-6 rounded shadow-2xl border border-gray-700 relative">
            <button onclick="closePayment()" class="absolute top-4 left-4 text-gray-400 hover:text-white text-2xl">&times;</button>
            
            <h2 class="text-2xl font-bold text-white mb-4 text-center">إتمام الشراء (عبر بوابة Paymob) 💳</h2>
            
            <!-- معلومات اللعبة والسعر -->
            <div class="panel-bg p-4 rounded mb-6 text-center border border-[#2a475e]">
                <p id="pay-game-name" class="text-gray-300 text-sm mb-1"></p>
                <p id="pay-game-price" class="text-2xl font-bold text-green-400"></p>
                <p class="text-xs text-gray-400 mt-2">الأرباح تحول مباشرة إلى الحساب البنكي للمطورين (Yoyo & Yaya)</p>
            </div>

            <!-- فورم بيانات الفيزا -->
            <form id="visaForm" class="space-y-4">
                <div>
                    <label class="block text-xs font-bold mb-1 text-gray-400">رقم البطاقة (16 رقم)</label>
                    <input type="text" required pattern="\d{16}" title="يجب إدخال 16 رقم" placeholder="1234 5678 9101 1121" class="input-field w-full p-3 rounded text-left tracking-widest" dir="ltr" maxlength="16">
                </div>
                <div class="flex gap-4">
                    <div class="flex-1">
                        <label class="block text-xs font-bold mb-1 text-gray-400">تاريخ الانتهاء</label>
                        <input type="text" required placeholder="MM/YY" class="input-field w-full p-3 rounded text-center" dir="ltr" maxlength="5">
                    </div>
                    <div class="flex-1">
                        <label class="block text-xs font-bold mb-1 text-gray-400">رمز الأمان (CVV)</label>
                        <input type="password" required pattern="\d{3}" title="يجب إدخال 3 أرقام" placeholder="123" class="input-field w-full p-3 rounded text-center" dir="ltr" maxlength="3">
                    </div>
                </div>
                <button type="submit" class="w-full py-3 mt-4 rounded font-bold text-white bg-green-600 hover:bg-green-500 transition">
                    دفع وإضافة للمكتبة
                </button>
            </form>
        </div>
    </div>

    <!-- واجهة البرنامج (الـ Launcher) -->
    <div id="main-app" class="hidden flex h-screen">
        <!-- القائمة الجانبية -->
        <div class="sidebar w-64 flex flex-col shadow-2xl z-10 border-l border-gray-800 hidden md:flex">
            <div class="p-6">
                <h1 class="text-2xl font-bold text-white text-center mb-6">Yoyo X <span class="text-blue-400">Yaya</span></h1>
                <ul class="space-y-2">
                    <li id="btn-library" onclick="showSection('library')" class="nav-active p-3 rounded cursor-pointer transition">📚 المكتبة</li>
                    <li id="btn-store" onclick="showSection('store')" class="p-3 rounded cursor-pointer transition hover:bg-white hover:bg-opacity-10">🛒 المتجر</li>
                </ul>
            </div>
            <div class="p-6 mt-auto border-t border-gray-700">
                <div id="desktop-username" class="text-white font-bold"></div>
                <div id="desktop-role" class="text-xs"></div>
            </div>
        </div>

        <!-- مساحة العرض الرئيسية -->
        <div class="flex-1 overflow-y-auto bg-[#1b2838] relative">
            
            <!-- قسم المكتبة -->
            <div id="section-library" class="p-8 block">
                <h2 class="text-3xl text-white font-bold mb-6 border-b border-gray-700 pb-2">مكتبة الألعاب</h2>
                <div id="library-grid" class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6"></div>
            </div>

            <!-- قسم المتجر -->
            <div id="section-store" class="p-8 hidden">
                <h2 class="text-3xl text-white font-bold mb-6 border-b border-gray-700 pb-2">المتجر الرئيسي</h2>
                <div id="store-grid" class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6"></div>
            </div>

            <!-- صفحة تفاصيل اللعبة -->
            <div id="section-game-details" class="hidden">
                <div id="detail-bg" class="h-64 bg-cover bg-center opacity-30 absolute top-0 w-full" style="z-index: 0;"></div>
                <div class="relative z-10 p-8 pt-12">
                    <button onclick="showSection('store')" class="text-blue-400 hover:text-white mb-4">➔ العودة للمتجر</button>
                    <h1 id="detail-title" class="text-4xl text-white font-bold mb-6"></h1>
                    
                    <div class="flex flex-col lg:flex-row gap-6">
                        <div class="flex-1">
                            <img id="detail-main-img" class="w-full h-80 object-cover shadow-lg border border-gray-700 mb-2">
                        </div>
                        
                        <div class="lg:w-1/3 flex flex-col gap-4">
                            <img id="detail-cover" class="w-full shadow-lg">
                            <p id="detail-desc" class="text-sm text-gray-300 leading-relaxed"></p>
                            
                            <div class="text-xs text-gray-400 space-y-1 mt-2">
                                <p>المطور: <span class="text-blue-400">Yoyo & Yaya (أرباح 100% للمطورين)</span></p>
                                <p>المساحة المطلوبة: <span id="detail-size" class="text-white font-bold"></span></p>
                            </div>

                            <div class="panel-bg p-4 mt-auto rounded border border-gray-700">
                                <p class="text-white text-lg mb-3">شراء <span id="detail-buy-title"></span></p>
                                <div class="flex justify-between items-center bg-black bg-opacity-50 p-2 rounded">
                                    <span id="detail-price" class="text-xl font-bold text-white ml-4"></span>
                                    <button id="detail-buy-btn" class="steam-btn py-2 px-6 rounded font-bold transition">شراء الآن</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- كود التشغيل والمنطق -->
    <script>
        let currentUser = "";
        let isAdmin = false;
        let selectedGameId = null;

        const gamesDB = {
            "gta5": {
                title: "Grand Theft Auto V", price: "50.00$", size: "105 GB",
                cover: "https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/271590/header.jpg",
                screenshots: ["https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/271590/ss_b95c29415c4d0f622607421884e622b7a9561b62.1920x1080.jpg"],
                desc: "استكشف مدينة لوس سانتوس في واحدة من أضخم ألعاب العالم المفتوح."
            },
            "yoyo_game": {
                title: "لعبة Yoyo X Yaya الحصرية", price: "20.00$", size: "5 GB",
                cover: "https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/1174180/header.jpg",
                screenshots: ["https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/1174180/ss_891e4f447a1bc7e7b6c59b675546e556e4fcda3a.1920x1080.jpg"],
                desc: "أول لعبة حصرية لمنصتنا! من تطوير Yoyo و Yaya حصرياً."
            },
            "cs2": {
                title: "Counter-Strike 2", price: "مجانًا", size: "35 GB",
                cover: "https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/730/header.jpg",
                screenshots: ["https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/730/ss_37bc3eb3d2f93cb62ea0ba6797db3c574044be25.1920x1080.jpg"],
                desc: "الإصدار الأحدث من لعبة التصويب التنافسية الأسطورية."
            }
        };

        // تسجيل الدخول
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            currentUser = document.getElementById('usernameInput').value.toLowerCase().trim();
            isAdmin = ["yoyo", "yaya"].includes(currentUser);

            document.getElementById('login-screen').classList.add('hidden');
            document.getElementById('main-app').classList.remove('hidden');
            
            document.getElementById('desktop-username').innerText = currentUser.toUpperCase();
            document.getElementById('desktop-role').innerText = isAdmin ? "مدير النظام (Admin)" : "لاعب (User)";
            document.getElementById('desktop-role').className = isAdmin ? "text-xs text-red-400" : "text-xs text-blue-400";
            
            buildStore();
            addGameToLibrary("cs2");
        });

        // التنقل بين الأقسام
        function showSection(sectionName) {
            document.getElementById('section-library').classList.add('hidden');
            document.getElementById('section-store').classList.add('hidden');
            document.getElementById('section-game-details').classList.add('hidden');
            
            document.getElementById('btn-library').classList.remove('nav-active');
            document.getElementById('btn-store').classList.remove('nav-active');

            if(sectionName !== 'details') {
                document.getElementById('section-' + sectionName).classList.remove('hidden');
                document.getElementById('btn-' + sectionName).classList.add('nav-active');
            } else {
                document.getElementById('section-game-details').classList.remove('hidden');
            }
        }

        // بناء المتجر
        function buildStore() {
            const storeGrid = document.getElementById('store-grid');
            storeGrid.innerHTML = "";
            for (const [id, game] of Object.entries(gamesDB)) {
                let displayPrice = (isAdmin && game.price !== "مجانًا") ? "مجاناً للمدير" : game.price;
                let priceColor = (displayPrice === "مجانًا" || isAdmin) ? "text-green-400" : "text-white";
                
                storeGrid.innerHTML += `
                    <div onclick="openGameDetails('${id}')" class="game-card cursor-pointer">
                        <img src="${game.cover}" class="w-full h-32 object-cover">
                        <div class="p-3">
                            <h3 class="text-white font-bold truncate">${game.title}</h3>
                            <p class="${priceColor} mt-2 font-bold">${displayPrice}</p>
                        </div>
                    </div>
                `;
            }
        }

        // تفاصيل اللعبة
        function openGameDetails(gameId) {
            selectedGameId = gameId;
            const game = gamesDB[gameId];
            
            document.getElementById('detail-bg').style.backgroundImage = `url('${game.screenshots[0]}')`;
            document.getElementById('detail-title').innerText = game.title;
            document.getElementById('detail-main-img').src = game.screenshots[0];
            document.getElementById('detail-cover').src = game.cover;
            document.getElementById('detail-desc').innerText = game.desc;
            document.getElementById('detail-size').innerText = game.size; 
            document.getElementById('detail-buy-title').innerText = game.title;
            
            let finalPrice = (isAdmin && game.price !== "مجانًا") ? "مجاناً 🎁" : game.price;
            document.getElementById('detail-price').innerText = finalPrice;
            
            let btn = document.getElementById('detail-buy-btn');
            btn.innerText = (isAdmin || game.price === "مجانًا") ? "إضافة للمكتبة" : "شراء الآن";
            btn.onclick = () => handleBuyClick(gameId);

            showSection('details');
        }

        // التعامل مع الشراء أو فتح نافذة الفيزا
        function handleBuyClick(gameId) {
            const game = gamesDB[gameId];
            if(isAdmin || game.price === "مجانًا") {
                alert("✅ تمت الإضافة إلى مكتبتك بنجاح يا بطل!");
                addGameToLibrary(gameId);
                showSection('library');
            } else {
                document.getElementById('pay-game-name').innerText = "شراء: " + game.title;
                document.getElementById('pay-game-price').innerText = "المبلغ المطلوب: " + game.price;
                document.getElementById('visaForm').reset();
                document.getElementById('payment-modal').classList.remove('hidden');
            }
        }

        // محاكاة إتمام الدفع (عبر Paymob)
        document.getElementById('visaForm').addEventListener('submit', function(e) {
            e.preventDefault();
            alert("💳 تمت عملية الدفع بنجاح عبر Paymob!\nتم تحويل الأرباح لحسابك البنكي، وجاري إضافة اللعبة إلى مكتبتك.");
            closePayment();
            addGameToLibrary(selectedGameId);
            showSection('library');
        });

        function closePayment() {
            document.getElementById('payment-modal').classList.add('hidden');
        }

        // إضافة اللعبة للمكتبة
        const ownedGames = new Set();
        function addGameToLibrary(gameId) {
            if(ownedGames.has(gameId)) return; 
            ownedGames.add(gameId);
            const game = gamesDB[gameId];
            const libraryGrid = document.getElementById('library-grid');
            libraryGrid.innerHTML += `
                <div class="game-card flex flex-col">
                    <img src="${game.cover}" class="w-full h-32 object-cover">
                    <div class="p-4 flex-1 flex flex-col justify-between">
                        <h3 class="text-white font-bold mb-1">${game.title}</h3>
                        <button onclick="alert('🚀 جاري تشغيل ${game.title} .. بالتوفيق يا مطور!')" class="steam-btn py-2 px-4 rounded font-bold w-full uppercase text-sm mt-4">▶ تشغيل</button>
                    </div>
                </div>
            `;
        }
    </script>
</body>
</html>
