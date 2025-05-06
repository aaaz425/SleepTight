import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
  } from 'typeorm';
  
  @Entity('musics')
  export class Music {
    @PrimaryGeneratedColumn()
    id: number;
  
    @Column({ name: 'music_title', length: 50 })
    musicTitle: string;

    @Column({ name: 'music_stream_url', length: 200 })
    musicStreamUrl :string;
  
    @Column({ name: 'music_cover_img', length: 200, nullable: true })
    musicCoverImg?: string;
  
    @Column({ name: 'music_likes_count', type: 'int', default: 0 })
    musicLikesCount: number;
  
    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;
  
    @Column({ length: 100, nullable: true })
    category?: string;
  
    @Column('int', { array: true, name: 'user_list', nullable: true })
    userList?: number[];
  }