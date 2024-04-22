from sqlalchemy import create_engine, Column, Integer, String, Sequence
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import sessionmaker

Base = declarative_base()

class MockRecord(Base):
    __tablename__ = 'mockrecords'
    id = Column(Integer, Sequence('mock_id_seq'), primary_key=True)
    key = Column(String(80))
    value = Column(String(80))

engine = create_engine(f'mysql+pymysql://')

Base.metadata.create_all(engine)

Session = sessionmaker(bind = engine)
session = Session()

mock_records = []

for i in range(1,10):
   mock_records.append(MockRecord(key=f'00{i}',value=f'Mock_Record_00{i}_from_Mysql'))

session.add_all(mock_records)

session.commit()