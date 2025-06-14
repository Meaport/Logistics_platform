package com.logistics.transport.mapper;

import com.logistics.transport.dto.ShipmentDto;
import com.logistics.transport.dto.VehicleDto;
import com.logistics.transport.entity.Shipment;
import com.logistics.transport.entity.Vehicle;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

@Mapper(componentModel = "spring")
public interface TransportMapper {
    
    TransportMapper INSTANCE = Mappers.getMapper(TransportMapper.class);
    
    ShipmentDto shipmentToDto(Shipment shipment);
    VehicleDto vehicleToDto(Vehicle vehicle);
}
