<?php

$baseUrl = 'http://127.0.0.1/sportstudio_website/backend/public/api';

function login($email, $password) {
    global $baseUrl;
    $ch = curl_init("$baseUrl/login");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
        'email' => $email,
        'password' => $password,
    ]));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    $res = curl_exec($ch);
    echo "Login Response: $res\n";
    $data = json_decode($res, true);
    curl_close($ch);
    return $data['access_token'] ?? null;
}

function createDeal($token, $data) {
    global $baseUrl;
    $ch = curl_init("$baseUrl/deals");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        "Authorization: Bearer $token"
    ]);
    $res = curl_exec($ch);
    curl_close($ch);
    return json_decode($res, true);
}

function getPublicDeals() {
    global $baseUrl;
    $res = file_get_contents("$baseUrl/public/deals");
    return json_decode($res, true);
}

// 1. Login as Owner
echo "Logging in as Owner...\n";
$ownerToken = login('testowner@sportstudio.com', 'password');
if (!$ownerToken) {
    die("Owner login failed\n");
}
echo "Owner logged in successfully.\n\n";

// 2. Create a Deal (Simulating the Mobile App's Random Assignment)
// The Mobile App now does: 'color_theme': _selectedColorTheme ?? (_flavorColors..shuffle()).first
// Since the owner form removed the dropdown, _selectedColorTheme is null.
$flavorColors = ['orange', 'teal', 'blue', 'purple', 'pink', 'green'];
$randomColor = $flavorColors[array_rand($flavorColors)];

echo "Simulating Mobile App Deal Creation with Random Color: $randomColor...\n";
$dealData = [
    'title' => 'Flash Test Sale',
    'description' => 'Test deal created via manual test script',
    'discount_percentage' => 45,
    'code' => 'FLASHTEST',
    'valid_until' => date('Y-m-d', strtotime('+3 days')),
    'color_theme' => $randomColor, // This is what the mobile app sends now
];

$createRes = createDeal($ownerToken, $dealData);
echo "Creation Response: " . (isset($createRes['id']) ? "Success (ID: {$createRes['id']})" : json_encode($createRes)) . "\n\n";

// 3. Verify as User
echo "Fetching Public Deals to verify...\n";
$deals = getPublicDeals();
$found = false;
$dataList = isset($deals['data']) ? $deals['data'] : $deals;

foreach ($dataList as $deal) {
    if ($deal['code'] == 'FLASHTEST') {
        echo "✅ Deal Verified in Public List!\n";
        echo "Code: " . $deal['code'] . "\n";
        echo "Theme Color: " . $deal['color_theme'] . "\n";
        $found = true;
        break;
    }
}

if (!$found) {
    echo "❌ Deal not found in public list.\n";
}
