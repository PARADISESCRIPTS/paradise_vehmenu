import React, { useEffect, useState } from "react";
import "./App.css";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";
import { useVisibility } from "../providers/VisibilityProvider";
import { useNuiEvent } from "../hooks/useNuiEvent";

import leftDoorIcon from '../assets/left-door.png';
import rightDoorIcon from '../assets/right-door.png';
import rearLeftDoorIcon from '../assets/left-door.png';
import rearRightDoorIcon from '../assets/right-door.png';

import leftWindowIcon from '../assets/left-window.png';
import rightWindowIcon from '../assets/right-window.png';
import rearLeftWindowIcon from '../assets/left-window.png';
import rearRightWindowIcon from '../assets/right-window.png';

import driverSeatIcon from '../assets/car-seat.png';
import passengerSeatIcon from '../assets/car-seat.png';
import rearLeftSeatIcon from '../assets/car-seat.png';
import rearRightSeatIcon from '../assets/car-seat.png';

import trunkIcon from '../assets/car-trunk.png';
import hoodIcon from '../assets/car-hood.png';
import musicIcon from '../assets/car-music.png';
import keysIcon from '../assets/car-key.png';

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

interface Control {
  id: string;
  label: string;
  icon: string;
}

interface ControlSection {
  title: string;
  controls: Control[];
}

interface NuiResponse {
  success: boolean;
}

interface VehicleInfoResponse extends NuiResponse {
  seatingCapacity: number;
}

const App: React.FC = () => {
  const { visible, setVisible } = useVisibility();
  const [activeControls, setActiveControls] = useState<Record<string, boolean>>({});
  const [isAnimating, setIsAnimating] = useState(false);
  const [isDevelopment, setIsDevelopment] = useState(false);
  const [seatingCapacity, setSeatingCapacity] = useState<number>(4);

  useNuiEvent<{ newSeat: string; oldSeat: string }>('seatChanged', (data) => {
    setActiveControls(prev => {
      const newState = { ...prev };
      if (data.oldSeat) {
        newState[data.oldSeat] = false;
      }
      newState[data.newSeat] = true;
      return newState;
    });
  });

  useEffect(() => {
    if (visible) {
      setIsAnimating(true);
      setTimeout(() => setIsAnimating(false), 500);
      fetchNui<VehicleInfoResponse>('getVehicleInfo', {}).then((response) => {
        if (response?.success) {
          setSeatingCapacity(response.seatingCapacity);
        }
      });
    }
  }, [visible]);

  const handleToggleMenu = () => {
    setVisible(!visible);
  };

  const getSeatControls = () => {
    const seats = [
      { id: 'driver_seat', label: 'Driver', icon: driverSeatIcon },
      { id: 'passenger_seat', label: 'Passenger', icon: passengerSeatIcon },
    ];

    if (seatingCapacity > 2) {
      seats.push(
        { id: 'rear_left_seat', label: 'Rear Left', icon: rearLeftSeatIcon }
      );
    }
    if (seatingCapacity > 3) {
      seats.push(
        { id: 'rear_right_seat', label: 'Rear Right', icon: rearRightSeatIcon }
      );
    }
    if (seatingCapacity > 4) {
      seats.push(
        { id: 'rear_middle_seat', label: 'Rear Middle', icon: rearLeftSeatIcon }
      );
    }
    if (seatingCapacity > 5) {
      seats.push(
        { id: 'rear_extra_seat', label: 'Rear Extra', icon: rearRightSeatIcon }
      );
    }

    return seats;
  };

  const controlSections: Record<string, ControlSection> = {
    doors: {
      title: 'Doors',
      controls: [
        { id: 'left_door', label: 'Left', icon: leftDoorIcon },
        { id: 'right_door', label: 'Right', icon: rightDoorIcon },
        { id: 'rear_left_door', label: 'Rear Left', icon: rearLeftDoorIcon },
        { id: 'rear_right_door', label: 'Rear Right', icon: rearRightDoorIcon }
      ]
    },
    windows: {
      title: 'Windows',
      controls: [
        { id: 'left_window', label: 'Left', icon: leftWindowIcon },
        { id: 'right_window', label: 'Right', icon: rightWindowIcon },
        { id: 'rear_left_window', label: 'Rear Left', icon: rearLeftWindowIcon },
        { id: 'rear_right_window', label: 'Rear Right', icon: rearRightWindowIcon }
      ]
    },
    seats: {
      title: 'Seats',
      controls: getSeatControls()
    },
    others: {
      title: 'Others',
      controls: [
        { id: 'trunk', label: 'Trunk', icon: trunkIcon },
        { id: 'hood', label: 'Hood', icon: hoodIcon },
        { id: 'music', label: 'Music', icon: musicIcon },
        { id: 'keys', label: 'Keys', icon: keysIcon }
      ]
    }
  };

  const handleControlClick = async (controlId: string) => {
    try {
      const newState = !activeControls[controlId];
      console.log('Sending control:', controlId, newState);
      
      const response = await fetchNui<NuiResponse>('vehicleControl', {
        controlId,
        state: newState
      });
      
      if (response?.success) {
        setActiveControls(prev => ({
          ...prev,
          [controlId]: newState
        }));
      } else {
        console.error('Failed to receive response from server');
      }
    } catch (e) {
      console.error('Failed to send control state:', e);
    }
  };

  const renderControlSection = (section: string) => {
    const sectionData = controlSections[section];
    return (
      <div className={`control-section control-section-${section}`}>
        <div className="section-title">{sectionData.title}</div>
        <div className="hex-grid">
          {sectionData.controls.map((control) => (
            <button
              key={control.id}
              className={`hex-button ${activeControls[control.id] ? 'active' : ''}`}
              onClick={() => handleControlClick(control.id)}
            >
              <div className="hex-content">
                <img 
                  src={control.icon} 
                  alt={control.label} 
                  className="control-icon"
                  style={{ width: '24px', height: '24px' }}
                />
                <div className="hex-label">{control.label}</div>
              </div>
            </button>
          ))}
        </div>
      </div>
    );
  };

  return (
    <>
      {isDevelopment && (
        <div className="dev-controls">
          <button className="dev-button" onClick={handleToggleMenu}>
            {visible ? 'Close Menu' : 'Open Menu'}
          </button>
        </div>
      )}
      <div className={`vehicle-controls ${visible ? 'visible' : 'hidden'}`}>
        <div className="engine-start">
          <button 
            className="hex-button large"
            onClick={() => handleControlClick('engine')}
          >
            <div className="hex-content">
              <span className="hex-label">ENGINE</span>
              <span className="hex-sublabel">START</span>
            </div>
          </button>
        </div>
        <div className="controls-divider">
          <div className="divider-left"></div>
          <div className="divider-right"></div>
        </div>
        <div className="controls-grid">
          {renderControlSection("doors")}
          {renderControlSection("windows")}
          {renderControlSection("seats")}
          {renderControlSection("others")}
        </div>
      </div>
    </>
  );
};

export default App;
