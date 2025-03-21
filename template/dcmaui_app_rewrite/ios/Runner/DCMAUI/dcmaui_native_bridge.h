#ifndef DCMAUI_NATIVE_BRIDGE_H
#define DCMAUI_NATIVE_BRIDGE_H

#include <stdint.h>

// Event callback type
typedef void (*event_callback_t)(const char* view_id, const char* event_type, const char* event_data_json);

// Register Swift implementations
void dcmaui_register_swift_functions(
    int8_t (*init)(),
    int8_t (*create)(const char*, const char*, const char*),
    int8_t (*update)(const char*, const char*),
    int8_t (*delete)(const char*),
    int8_t (*attach)(const char*, const char*, int32_t),
    int8_t (*set_children)(const char*, const char*),
    int8_t (*add_listeners)(const char*, const char*),
    int8_t (*remove_listeners)(const char*, const char*)
);

// FFI functions
int8_t dcmaui_initialize();
int8_t dcmaui_create_view(const char* view_id, const char* type, const char* props_json);
int8_t dcmaui_update_view(const char* view_id, const char* props_json);
int8_t dcmaui_delete_view(const char* view_id);
int8_t dcmaui_attach_view(const char* child_id, const char* parent_id, int32_t index);
int8_t dcmaui_set_children(const char* view_id, const char* children_json);
int8_t dcmaui_add_event_listeners(const char* view_id, const char* events_json);
int8_t dcmaui_remove_event_listeners(const char* view_id, const char* events_json);
void dcmaui_set_event_callback(event_callback_t callback);

// For Swift to call to trigger events
void dcmaui_send_event(const char* view_id, const char* event_type, const char* event_data_json);

#endif // DCMAUI_NATIVE_BRIDGE_H
