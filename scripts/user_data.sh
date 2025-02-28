#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
cat << 'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Beautiful Static Website</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(to right, #ff7e5f, #feb47b);
            color: #fff;
            text-align: center;
        }
        header {
            padding: 50px 0;
            background: rgba(0, 0, 0, 0.5);
        }
        header h1 {
            font-size: 3em;
            margin: 0;
            animation: fadeInDown 2s;
        }
        section {
            padding: 50px 20px;
        }
        .content {
            max-width: 800px;
            margin: 0 auto;
            animation: fadeInUp 2s;
        }
        footer {
            padding: 20px 0;
            background: rgba(0, 0, 0, 0.5);
            margin-top: 80vh;
        }
        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
    <header>
        <h1>Welcome to My Beautiful Website</h1>
    </header>
    <section>
        <div class="content">
            <h2>About This Project</h2>
            <p>This is a simple static website designed to showcase beautiful animations and a clean layout. Feel free to explore and enjoy the smooth transitions!</p>
            <p>This was developed or spun up using terraform</p>
        </div>
    </section>
    <footer>
        <p>&copy; 2025 MawuliB. All rights reserved.</p>
    </footer>
</body>
</html>
EOF
sudo systemctl start nginx
sudo systemctl enable nginx