import asyncpg
import asyncio
from typing import Optional
from app.core.config import settings

# Database connection pool
db_pool: Optional[asyncpg.Pool] = None

async def init_db():
    """Initialize database connection pool"""
    global db_pool
    
    try:
        db_pool = await asyncpg.create_pool(
            settings.DATABASE_URL,
            min_size=5,
            max_size=20
        )
        print("Database connection pool created successfully")
    except Exception as e:
        print(f"Error creating database pool: {e}")
        raise

async def get_db():
    """Get database connection from pool"""
    if db_pool is None:
        await init_db()
    return db_pool

async def close_db():
    """Close database connection pool"""
    global db_pool
    if db_pool:
        await db_pool.close()
        print("Database connection pool closed")
