<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit(); }

require_once 'db_connect.php';

switch ($_SERVER['REQUEST_METHOD']) {
    case 'GET':    getTasks($conn);   break;
    case 'POST':   addTask($conn);    break;
    case 'PUT':    updateTask($conn); break;
    case 'DELETE': deleteTask($conn); break;
    default: http_response_code(405); echo json_encode(["success"=>false,"message"=>"Method not allowed"]);
}
$conn->close();

function rowToArray($row) {
    return [
        "id"         => (int)  $row['id'],
        "title"      =>        $row['title'],
        "is_done"    => (bool) $row['is_done'],
        "priority"   =>        $row['priority'],
        "deadline"   =>        $row['deadline'],
        "created_at" =>        $row['created_at'],
        "updated_at" =>        $row['updated_at'],
    ];
}

function getTasks($conn) {
    $sql = "SELECT * FROM tasks ORDER BY FIELD(priority,'high','medium','low'), deadline IS NULL, deadline ASC";
    $result = $conn->query($sql);
    if (!$result) { http_response_code(500); echo json_encode(["success"=>false,"message"=>$conn->error]); return; }
    $tasks = [];
    while ($row = $result->fetch_assoc()) $tasks[] = rowToArray($row);
    echo json_encode(["success"=>true,"data"=>$tasks]);
}

function addTask($conn) {
    $body = json_decode(file_get_contents("php://input"), true);
    if (empty($body['title']) || trim($body['title']) === '') { http_response_code(400); echo json_encode(["success"=>false,"message"=>"Title required"]); return; }
    $title    = $conn->real_escape_string(trim($body['title']));
    $priority = in_array($body['priority']??'',['low','medium','high']) ? $body['priority'] : 'medium';
    $deadline = !empty($body['deadline']) ? "'".$conn->real_escape_string($body['deadline'])."'" : "NULL";
    if (!$conn->query("INSERT INTO tasks (title,priority,deadline) VALUES ('$title','$priority',$deadline)")) {
        http_response_code(500); echo json_encode(["success"=>false,"message"=>$conn->error]); return;
    }
    $id  = $conn->insert_id;
    $row = $conn->query("SELECT * FROM tasks WHERE id=$id")->fetch_assoc();
    http_response_code(201);
    echo json_encode(["success"=>true,"message"=>"Added","data"=>rowToArray($row)]);
}

function updateTask($conn) {
    $body = json_decode(file_get_contents("php://input"), true);
    if (empty($body['id']) || !is_numeric($body['id'])) { http_response_code(400); echo json_encode(["success"=>false,"message"=>"Valid ID required"]); return; }
    $id = (int)$body['id'];
    if ($conn->query("SELECT id FROM tasks WHERE id=$id")->num_rows === 0) { http_response_code(404); echo json_encode(["success"=>false,"message"=>"Not found"]); return; }
    $parts = [];
    if (isset($body['title']) && trim($body['title'])!=='') $parts[] = "title='".$conn->real_escape_string(trim($body['title']))."'";
    if (isset($body['is_done'])) $parts[] = "is_done=".($body['is_done']?1:0);
    if (isset($body['priority']) && in_array($body['priority'],['low','medium','high'])) $parts[] = "priority='".$body['priority']."'";
    if (array_key_exists('deadline',$body)) $parts[] = "deadline=".(!empty($body['deadline'])?"'".$conn->real_escape_string($body['deadline'])."'":"NULL");
    if (empty($parts)) { http_response_code(400); echo json_encode(["success"=>false,"message"=>"Nothing to update"]); return; }
    $conn->query("UPDATE tasks SET ".implode(',',$parts)." WHERE id=$id");
    $row = $conn->query("SELECT * FROM tasks WHERE id=$id")->fetch_assoc();
    echo json_encode(["success"=>true,"message"=>"Updated","data"=>rowToArray($row)]);
}

function deleteTask($conn) {
    $body = json_decode(file_get_contents("php://input"), true);
    $id   = isset($body['id'])?(int)$body['id']:(int)($_GET['id']??0);
    if ($id<=0) { http_response_code(400); echo json_encode(["success"=>false,"message"=>"Valid ID required"]); return; }
    $conn->query("DELETE FROM tasks WHERE id=$id");
    echo json_encode(["success"=>true,"message"=>"Deleted"]);
}
?>
