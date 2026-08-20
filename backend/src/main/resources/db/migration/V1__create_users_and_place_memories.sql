create table users (
    id bigint not null auto_increment,
    email varchar(120) not null,
    password varchar(255) not null,
    nickname varchar(40) not null,
    created_at datetime(6) not null,
    primary key (id),
    constraint uk_users_email unique (email)
);

create table place_memories (
    id bigint not null auto_increment,
    user_id bigint not null,
    title varchar(120) not null,
    memo text not null,
    latitude decimal(10, 7) not null,
    longitude decimal(10, 7) not null,
    address varchar(255) not null,
    is_public boolean not null,
    created_at datetime(6) not null,
    updated_at datetime(6) not null,
    primary key (id),
    constraint fk_place_memories_user foreign key (user_id) references users (id)
);

create index idx_place_memories_user_created_at on place_memories (user_id, created_at);
create index idx_place_memories_public_created_at on place_memories (is_public, created_at);

create table place_memory_images (
    id bigint not null auto_increment,
    place_memory_id bigint not null,
    image_url varchar(500) not null,
    original_filename varchar(255),
    content_type varchar(80),
    size_bytes bigint,
    sort_order integer not null,
    primary key (id),
    constraint fk_place_memory_images_place_memory foreign key (place_memory_id) references place_memories (id)
);

create index idx_place_memory_images_place_memory_sort on place_memory_images (place_memory_id, sort_order);
